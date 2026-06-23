local function compile_run()
	local ft = vim.bo.filetype
	local run_cmd

	if ft == "c" then
		run_cmd = "!gcc % -o %< && time ./%<"
	elseif ft == "cpp" then
		run_cmd = "!g++ -std=c++11 % -Wall -o %< && time ./%<"
	elseif ft == "java" then
		run_cmd = "!javac % && time java %<"
	elseif ft == "sh" then
		run_cmd = "!time bash %"
	elseif ft == "python" then
		vim.cmd("sp | term python3 %")
		return
	elseif ft == "javascript" or ft == "typescript" then
		vim.cmd("sp | term node --trace-warnings .")
		return
	elseif ft == "go" then
		vim.cmd("sp | term go run .")
		return
	else
		vim.notify("No compile/run handler for " .. ft, vim.log.levels.WARN)
		return
	end

	vim.cmd("w")
	vim.cmd(run_cmd)
end

vim.keymap.set("n", "<leader>r", compile_run, { noremap = true, desc = "Compile and run current file" })
