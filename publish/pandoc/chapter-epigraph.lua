-- Wrap the blockquote that directly follows a level-1 heading in a
-- \begin{epigraph}…\end{epigraph} environment and append \clearpage,
-- so every book opens on its own page with the citation centred
-- vertically and the first verse starts on the next page.
--
-- Only runs for the LaTeX writer; EPUB and HTML builds get the usual
-- blockquote rendering.

function Pandoc(doc)
  if FORMAT ~= 'latex' then return nil end

  local out = {}
  local i = 1
  local blocks = doc.blocks
  while i <= #blocks do
    local b = blocks[i]
    local next_b = blocks[i + 1]
    if b.t == 'Header' and b.level == 1
        and next_b and next_b.t == 'BlockQuote' then
      table.insert(out, b)
      -- Render the blockquote's inner blocks to LaTeX so inline markdown
      -- (italic, inline code, hard breaks) converts correctly.
      local inner = pandoc.write(pandoc.Pandoc(next_b.content), 'latex')
      table.insert(out, pandoc.RawBlock('latex',
        '\\begin{epigraph}\n' .. inner .. '\\end{epigraph}\n\\clearpage'))
      i = i + 2
    else
      table.insert(out, b)
      i = i + 1
    end
  end
  return pandoc.Pandoc(out, doc.meta)
end
