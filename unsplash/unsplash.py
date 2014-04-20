#!/usr/bin/env python

import urllib
import pprint
import os

def getImageURLs(pageIndex):
    f = urllib.urlopen('http://unsplash.com/page/' + str(pageIndex))
    data = f.read()
    f.close()

    curPage = None
    numPages = None
    imgUrls = [ ]

    for l in data.splitlines():
        if 'Download' in l and 'src=' in l:
            idx = l.find('src="')
            if idx >= 0:
                idx2 = l.find('"', idx+5)
                if idx2 >= 0:
                    imgUrls.append(l[idx+5:idx2])

        elif 'current_page = ' in l:
            idx = l.find('=')
            idx2 = l.find(';', idx)
            curPage = int(l[idx+1:idx2].strip())
        elif 'total_pages = ' in l:
            idx = l.find('=')
            idx2 = l.find(';', idx)
            numPages = int(l[idx+1:idx2].strip())

    return (curPage, numPages, imgUrls)

def retrieveAndSaveFile(fileName, url):
    f = urllib.urlopen(url)
    data = f.read()
    f.close()

    g = open(fileName, "wb")
    g.write(data)
    g.close()

if  __name__ == "__main__":

    allImages = [ ]
    done = False
    page = 1
    while not done:
        print "Retrieving URLs on page", page
        res = getImageURLs(page)
        allImages += res[2]

        if res[0] >= res[1]:
            done = True
        else:
            page += 1

    for url in allImages:
        idx = url.rfind('/')
        fileName = url[idx+1:]
        if not os.path.exists(fileName):
            print "File", fileName, "not found locally, downloading from", url
            retrieveAndSaveFile(fileName, url)

    print "Done."