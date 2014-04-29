0. Clean ghc packages in User/AppData/Roaming/[Cabal | GHC] and the base uninstaller if packages are FUBAR

0. (Optional) Allow dynamic compilation of site.hs (this reduces the produced binary by ~99%)
	A) To get cabal source and config files, open GHCi and use:
		i)  :m System.Directory
		ii) getAppUserDataDirectory "cabal"
	B) Append "shared: true" to the config file in this directory
	C) Install the dynamic hakyll package using "cabal install --enable-shared hakyll"

1. Initialize site.exe using:
	A) hakyll-init site-name
	B) cd site-name
	C) ghc --make -threaded site.hs
	D) site build
	E) site watch
	
2. Preview by connecting to http://localhost:8000/

3. Create and push a git repository to GitHub

4. Host on GitHub Pages

5. Write a batch script to deal with the "site rebuild" command which deletes _site subdirectory, which includes the .git resources:

@ECHO OFF
SETLOCAL EnableDelayedExpansion
set "sourcedir=%SITEPATH%\_site"
set "destdir=%SITEPATH%\temp"
if not exist "%destdir%\.git" mkdir "%destdir%\.git"
xcopy "%sourcedir%\.gitignore" %destdir% /s /Y
xcopy "%sourcedir%\README.md" %destdir% /s /Y
xcopy "%sourcedir%\.git" "%destdir%\.git" /s /Y /D
del %sourcedir%\*.* /s /F /Q
site rebuild
xcopy %destdir%  %sourcedir% /s /Y
mkdir "%sourcedir%\.git"
xcopy "%destdir%\.git" "%sourcedir%\.git" /s /Y /D
pause 