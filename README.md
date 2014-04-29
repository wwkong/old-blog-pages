0. Clean ghc packages in ~./User/AppData/Roaming/[Cabal | GHC] and the base uninstaller if packages are FUBAR

0. (Optional, but highly recommended [does not work in Windows]) Allow dynamic compilation of site.hs 
	=> This reduces the size of the produced binary by ~99% and compile time by 80%
	A) To get cabal source and config files, open GHCi and use:
		i)  :m System.Directory
		ii) getAppUserDataDirectory "cabal"
	B) Append "shared: true" to the config file in this directory
	C) Install the dynamic hakyll package using "cabal install --enable-shared hakyll"
	D) In Windows, there is currently no way to reference all necessary DLLs in the compiled binary

1. Initialize site.exe using:
	A) hakyll-init site-name
	B) cd site-name
	C) ghc --make -threaded -dynamic site.hs
	D) site build
	E) site watch
	
2. Preview by connecting to http://localhost:8000/

3. Create and push a git repository to GitHub on the _site subdirectory
	A) Make sure the repo name is username.github.io
	B) This is then hosted on GitHub pages under the above repo name as the url

5. Write a batch script to deal with the "site rebuild" command which deletes _site subdirectory, which includes the .git resources:

@ECHO OFF
SETLOCAL EnableDelayedExpansion
set "sourcedir=%CD%\_site"
set "destdir=%CD%\temp"
if not exist "%destdir%\.git" mkdir "%destdir%\.git"
xcopy "%sourcedir%\.gitignore" %destdir% /s /Y >nul
xcopy "%sourcedir%\README.md" %destdir% /s /Y >nul
xcopy "%sourcedir%\.git" "%destdir%\.git" /s /Y /D >nul
del %sourcedir%\*.* /s /F /Q >nul
ghc --make -dynamic site.hs
site rebuild
xcopy %destdir%  %sourcedir% /s /Y >nul
mkdir "%sourcedir%\.git" >nul
xcopy "%destdir%\.git" "%sourcedir%\.git" /s /Y /D >nul
pause 