const svg = document.getElementById('svg');
const canvas = document.getElementById('canvas');
const path = document.getElementById('tile');
const a_input = document.getElementById('a');
const b_input = document.getElementById('b');
const curve_input = document.getElementById('curve');
const a_output = document.getElementById('a_output');
const b_output = document.getElementById('b_output');
const curve_output = document.getElementById('curve_output');
const download_svg_link = document.getElementById('download-svg');
const download_png_link = document.getElementById('download-png');

let draw_timeout = null;

function debounce_draw(fn) {
    if(draw_timeout) {
        clearTimeout(draw_timeout);
    }
    draw_timeout = setTimeout(fn, 500);
}

async function draw() {

    const {cos,sin} = Math;

    const [c,s] = [cos(Math.PI/3),sin(Math.PI/3)];

    let a = parseFloat(a_input.value);
    let b = parseFloat(b_input.value);
    let curve = parseFloat(curve_input.value);

    const moves = [
        [c*b, s*b],
        [b,0],
        [0,a],
        [s*a, c*a],
        [c*b, -s*b],
        [-c*b, -s*b],
        [s*a, -c*a],
        [0, -a],
        [0, -a],
        [-s*a, -c*a],
        [-c*b, s*b],
        [-b, 0],
        [0, a],
        [-s*a, c*a],
    ];

    const width = (1+c)*b + 2*s*a;
    const yoff = s*b + (1+c)*a;
    const height = 2*s*b + 2*(1+c)*a;
    const margin = 0.1;

    function twiddle([x,y]) {
        const [nx,ny] = [y,-x];
        return [-curve*nx+x/2, -curve*ny+y/2, curve*nx+x/2, curve*ny+y/2, x, y];
    }

    svg.setAttribute('viewBox', `${-width*margin} ${-height*margin - yoff} ${width*(1+2*margin)} ${height*(1 + 2*margin)}`);

    const segment = (p) => 'c '+twiddle(p).join(' ');

    const d = 'M 0 0 ' + moves.map(segment).join(' ') + ' z';

    a_output.textContent = a.toFixed(3);
    b_output.textContent = b.toFixed(3);
    curve_output.textContent = curve.toFixed(3);

    path.setAttribute('d', d);

    const svg_url = URL.createObjectURL(new Blob([svg.outerHTML], { type: 'image/svg+xml' }));
    const filename = `monotile-${a.toFixed(3)}-${b.toFixed(3)}-${curve.toFixed(3)}`;
    download_svg_link.href = svg_url;
    download_svg_link.setAttribute('download',`${filename}.svg`);
    download_png_link.setAttribute('download',`${filename}.png`);
    download_png_link.removeAttribute('href');

    async function draw_png() {
        const scale = 1000;
        const canvas = new OffscreenCanvas(width*scale*(1+2*margin), height*scale*(1+2*margin));
        const ctx = canvas.getContext('2d');
        ctx.beginPath();
        ctx.scale(scale,scale);
        ctx.translate(margin*width,margin*height + yoff);
        ctx.moveTo(0,0);
        let x = 0, y = 0;
        for(let [dx,dy] of moves) {
            const [dx1,dy1,dx2,dy2,x1,y1] = twiddle([dx,dy]);
            ctx.bezierCurveTo(dx1+x, dy1+y, dx2+x, dy2+y, x+dx, y+dy);
            x += dx;
            y += dy;
        }
        ctx.closePath();
        ctx.fillStyle = 'white';
        ctx.fill();
        ctx.strokeStyle = 'black';
        ctx.lineWidth = 0.1;
        ctx.lineJoin = 'round';
        ctx.stroke();
        const blob = await canvas.convertToBlob();
        download_png_link.href = URL.createObjectURL(blob);
    }

    debounce_draw(draw_png);
}

draw();


function download_links() {
    console.log(svg.outerHTML);

    console.log('svg_url',svg_url);
    
    const svg_image = document.createElement('img');
    console.log('svg_image', svg_image);
    document.body.appendChild(svg_image);
    svg_image.onload = async function () {
        const canvas = new OffscreenCanvas(svg_image.clientWidth, svg_image.clientHeight);
        const canvasCtx = canvas.getContext('2d');
        canvasCtx.drawImage(svg_image, 0, 0);
        canvasCtx.fillRect(0,0,50,50);
        const blob = await canvas.convertToBlob();

        const png_image = document.createElement('img');
        document.body.appendChild(png_image);
        console.log(blob);
        png_image.src = URL.createObjectURL(blob);
    };
    svg_image.src = svg_url;

}

//download_links();

[a_input, b_input, curve_input].forEach(i => i.addEventListener('input', () => draw()));
