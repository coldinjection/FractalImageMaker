function newtonItr(fun::Function, min::Complex, max::Complex,
    wid::Int = 800, hgt::Int = 600)
    x = range(min.re, max.re, length = wid)
    y = range(min.im, max.im, length = hgt)
    val = fill(Int32(0), (hgt, wid))
    dfun(x) = central_fdm(5,1)(fun, x)
    for pos in eachindex(val)
        yin::Int32 = floor(Int32, pos / wid)
        xin::Int32 = pos % wid
        xin == 0 ? xin = wid : yin += 1
        c = ComplexF32(x[xin], y[yin])
        n::Int32 = 0
        for i in 1:40
            p = fun(c)
            abs(p) < Float32(1e-8) && break
            c = c - p / dfun(c)
            n += 1
        end
        val[pos] = n
    end
    return val
end
