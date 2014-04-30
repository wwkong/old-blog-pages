Development Log
=====

__1.__ Clean ghc packages in ~./User/AppData/Roaming/[Cabal | GHC] and the base uninstaller if packages are FUBAR   

* Install haddock-2.13.2 (for ghc 7.6.3), ghc-mod, haskell-src-ext

__2.__ (Optional) Allow dynamic compilation of site.hs  

* To get cabal source and config files, open GHCi and use:
	
````haskell
:m System.Directory
getAppUserDataDirectory "cabal"
````  

* Append "shared: true" to the config file in this directory  
* Install the dynamic hakyll package using "cabal install --enable-shared hakyll"
* In Windows, there is currently no way to reference all necessary DLLs in the compiled binary

__3.__ Initialize site.exe using:  
* hakyll-init site-name  
* cd site-name  
* ghc --make -threaded -dynamic site.hs  
* site build
* site watch
	
__4.__ Preview by connecting to http://localhost:8000/

__5.__ Create and push a git repository to GitHub on the _site subdirectory  
* Make sure the repo name is username.github.io  
* This is then hosted on GitHub pages under the above repo name as the url

__6.__ Write a batch script to deal with the "site rebuild" command which deletes _site subdirectory, which includes the .git resources:  

````bat
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

__7.__ Customize site.hs using a custom script:

````bat
@ECHO OFF  
SETLOCAL EnableDelayedExpansion  
cd "%CD%\_site"  
git add .  
git commit -m "Deployed content using custom batch script."  
git push --progress origin master:master  
pause
````

__8.__ Add a script to preview website:

````bat
@ECHO OFF
SETLOCAL EnableDelayedExpansion
START chrome "http://localhost:8000/"
site watch
````

__8.__ Customize site.hs with more routes and tags:
* A guide for tags can be found [here](http://javran.github.io/posts/2014-03-01-add-tags-to-your-hakyll-blog.html).

__9.__ Modify post.html to display author name and description.

__10.__ Add code for MathJax in the post.html template:
* Guides can be found [here](http://qnikst.github.io/posts/2013-02-04-hakyll-latex.html) and [here](http://www.dancingfrog.co.uk/posts/2013-09-05-adding-mathjax-to-hakyll).