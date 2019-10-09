function newtonItr(fun::Function, min::Complex, max::Complex,
                                    wid::Int = 800, hgt::Int = 600)
    x = range(min.re, max.re, length = wid)
    y = range(min.im, max.im, length = hgt)
    val = fill(Int32(0), (hgt, wid))
    dfun(x) = central_fdm(5,1)(fun, x)
    for xin in 1:wid
        for yin in 1:hgt
            c = ComplexF32(x[xin], y[yin])
            n::Int32 = 0
            for i in 1:40
                p = fun(c)
                abs(p) < Float32(1e-8) && break
                c = c - p / dfun(c)
                n += 1
            end
            val[yin, xin] = n
        end
    end
    return val
end
