struct ColourMark
    pos::Float32
    c::RGB{N0f8}
    ColourMark(pos::Float32, c::RGB) = new(pos, RGB{N0f8}(c))
end
function ColourMark(pos, r, g, b)
    0 <= pos <= 1 || error("pos has to be within [0, 1]")
    return ColourMark(Float32(pos), RGB{N0f8}(r, g, b))
end

mutable struct ColourMap
    marks::Vector{ColourMark}
end
function ColourMap(marks::Vararg{ColourMark})
    sorted_marks::Vector{ColourMark} = []
    for mk in marks
        inserted::Bool = false
        for i in 1:length(sorted_marks)
            if mk.pos < sorted_marks[i].pos
                insert!(sorted_marks, i, mk)
                inserted = true
                break
            end
        end
        inserted || push!(sorted_marks, mk)
    end
    if sorted_marks[1].pos != 0
        insert!(sorted_marks, 1, ColourMark(0f0, sorted_marks[1].c))
    end
    if sorted_marks[end].pos != 1
        push!(sorted_marks, ColourMark(1f0, sorted_marks[end].c))
    end
    return ColourMap(sorted_marks)
end
ColourMap(mark::ColourMark) = ColourMap([mark])

@inline vectorize(p::RGB) = Vector{Float32}([p.r, p.g, p.b])

function valColour(val, cmap::ColourMap, llim = 0.0f0, ulim = 1.0f0)
    valpos::Float32 = (val - llim) / (ulim - llim)
    valpos == 0 && return cmap.marks[1].c
    valpos == 1 && return cmap.marks[end].c
    nextind::Int = 0
    for i in eachindex(cmap.marks)
        valpos <= cmap.marks[i].pos && (nextind = i; break)
    end
    prevc = vectorize(cmap.marks[nextind - 1].c)
    prevp = cmap.marks[nextind - 1].pos
    nextc = vectorize(cmap.marks[nextind].c)
    nextp = cmap.marks[nextind].pos
    return RGB{N0f8}(prevc + (nextc - prevc) * (valpos - prevp) / (nextp - prevp)...)
end

function makeImage(val::Array, cmap::ColourMap)
    img = similar(val, RGB{N0f8})
    llim, ulim = extrema(val)
    img = map(x -> valColour(x, cmap, llim, ulim), val)
    return img
end
