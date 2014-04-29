Development Log
=====

1. Clean ghc packages in ~./User/AppData/Roaming/[Cabal | GHC] and the base uninstaller if packages are FUBAR  
	A) Install haddock-2.13.2 (for ghc 7.6.3), ghc-mod, haskell-src-ext

2. (Optional, but highly recommended [does not work in Windows]) Allow dynamic compilation of site.hs  
	=> This reduces the size of the produced binary by ~99% and compile time by 80%  
	A) To get cabal source and config files, open GHCi and use:  
````haskell
:m System.Directory
getAppUserDataDirectory "cabal"
````
	B) Append "shared: true" to the config file in this directory  
	C) Install the dynamic hakyll package using "cabal install --enable-shared hakyll"  
	D) In Windows, there is currently no way to reference all necessary DLLs in the compiled binary

3. Initialize site.exe using:  
	A) hakyll-init site-name  
	B) cd site-name  
	C) ghc --make -threaded -dynamic site.hs  
	D) site build  
	E) site watch
	
4. Preview by connecting to http://localhost:8000/

5. Create and push a git repository to GitHub on the _site subdirectory  
	A) Make sure the repo name is username.github.io  
	B) This is then hosted on GitHub pages under the above repo name as the url

6. Write a batch script to deal with the "site rebuild" command which deletes _site subdirectory, which includes the .git resources:  

````batch
@ECHO OFF  
SETLOCAL EnableDelayedExpansion  
if not exist "%CD%\temp" mkdir "%CD%\temp"  
set "sourcedir=%CD%\_site"  
set "destdir=%CD%\temp"  
if not exist "%destdir%\.git" mkdir "%destdir%\.git"  
xcopy "%sourcedir%\.gitignore" %destdir% /s /Y >nul  
xcopy "%sourcedir%\README.md" %destdir% /s /Y >nul  
xcopy "%sourcedir%\.git" "%destdir%\.git" /s /Y /D >nul  
del %sourcedir%\*.* /s /F /Q >nul  
ghc --make -threaded site.hs  
site rebuild  
xcopy %destdir%  %sourcedir% /s /Y >nul  
mkdir "%sourcedir%\.git" >nul  
xcopy "%destdir%\.git" "%sourcedir%\.git" /s /Y /D >nul  
del "%destdir%\*.*" /S /A /Q >nul  
for /f %%a in ('dir %destdir% /b /s /a:hd') do rd /s /q "%%a" >nul  
rd %destdir% >nul  
pause
````

7. Customize site.hs using a custom script:

@ECHO OFF  
SETLOCAL EnableDelayedExpansion  
cd "%CD%\_site"  
git add .  
git commit -m "Deployed content using custom batch script."  
git push --progress origin master:master  
pause
