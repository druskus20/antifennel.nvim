local Antifennel = {}

local defaults = {
    antifennel_command = "antifennel",
    tmp_file = "/tmp/antifennel_tmp",
}

function Antifennel.setup(options)
  Antifennel.options = vim.tbl_deep_extend("force", defaults, options or {})
end


function _split_lines(text)
  lines = {}
  for s in text:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  return lines
end

function _antifennel(text)
  local file = io.open(Antifennel.options.tmp_file, "w")
  io.output(file)
  io.write(text)
  io.close()
  return vim.fn.system(Antifennel.options.antifennel_command .. " " .. Antifennel.options.tmp_file)
end 

function _get_visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow - 1, cscol - 1, cerow - 1, cecol
  else
    return cerow - 1, cecol - 1, csrow - 1, cscol
  end
end

function _get_selected_text(csrow, cscol, cerow, cecol)
  local lines = vim.fn.getline(csrow + 1, cerow + 1)
  lines[1] = string.sub(lines[1], cscol + 1)
  lines[#lines] = string.sub(lines[#lines], 1, cecol)
  return table.concat(lines, "\n")
end


function Antifennel.convert_selection()
  local csrow, cscol, cerow, cecol = _get_visual_selection_range()
  local text = _get_selected_text(csrow, cscol, cerow, cecol)
  local result = _antifennel(text)
  local lines = _split_lines(result)
  vim.api.nvim_buf_set_lines(0, csrow, cerow, false, lines)
end

return Antifennel
