--------------------------------------------------------
--  DDL for Package FARX_C_MCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_C_MCR" AUTHID CURRENT_USER AS
/* $Header: FARXCMCRS.pls 120.0.12010000.2 2009/07/19 11:52:55 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Mass_Change_Review
|
|   Description:   Concurrent wrapper procedure for mass change review.
|                  This procedure calls the inner procedure,
|                  FARX_CR.Review_Change() that actually performs
|                  review of a mass change transaction.
|
|   Parameters:    retcode -- OUT parameter.  Denotes completion status.
|                       0 -- Completed normally.
|                       1 -- Completed with warning.
|                       2 -- Completed with error.
|                  errbuf -- OUT parameter.  Error or warning description.
|                  argument1..argument100 -- 100 arguments for concurrent request.
|                  argument1 -- Mass Change Id.
|
|
|   Returns:
|
|   Notes:
|
+=====================================================================================*/

PROCEDURE Mass_Change_Review(
     errbuf              OUT NOCOPY VARCHAR2,
     retcode             OUT NOCOPY VARCHAR2,
     argument1           IN     VARCHAR2,
     argument2           IN     VARCHAR2 := NULL,
     argument3           IN     VARCHAR2 := NULL,
     argument4           IN     VARCHAR2 := NULL,
     argument5           IN     VARCHAR2 := NULL,
     argument6           IN     VARCHAR2 := NULL,
     argument7           IN     VARCHAR2 := NULL,
     argument8           IN     VARCHAR2 := NULL,
     argument9           IN     VARCHAR2 := NULL,
     argument10          IN     VARCHAR2 := NULL,
     argument11          IN     VARCHAR2 := NULL,
     argument12          IN     VARCHAR2 := NULL,
     argument13          IN     VARCHAR2 := NULL,
     argument14          IN     VARCHAR2 := NULL,
     argument15          IN     VARCHAR2 := NULL,
     argument16          IN     VARCHAR2 := NULL,
     argument17          IN     VARCHAR2 := NULL,
     argument18          IN     VARCHAR2 := NULL,
     argument19          IN     VARCHAR2 := NULL,
     argument20          IN     VARCHAR2 := NULL,
     argument21          IN     VARCHAR2 := NULL,
     argument22          IN     VARCHAR2 := NULL,
     argument23          IN     VARCHAR2 := NULL,
     argument24          IN     VARCHAR2 := NULL,
     argument25          IN     VARCHAR2 := NULL,
     argument26          IN     VARCHAR2 := NULL,
     argument27          IN     VARCHAR2 := NULL,
     argument28          IN     VARCHAR2 := NULL,
     argument29          IN     VARCHAR2 := NULL,
     argument30          IN     VARCHAR2 := NULL,
     argument31          IN     VARCHAR2 := NULL,
     argument32          IN     VARCHAR2 := NULL,
     argument33          IN     VARCHAR2 := NULL,
     argument34          IN     VARCHAR2 := NULL,
     argument35          IN     VARCHAR2 := NULL,
     argument36          IN     VARCHAR2 := NULL,
     argument37          IN     VARCHAR2 := NULL,
     argument38          IN     VARCHAR2 := NULL,
     argument39          IN     VARCHAR2 := NULL,
     argument40          IN     VARCHAR2 := NULL,
     argument41          IN     VARCHAR2 := NULL,
     argument42          IN     VARCHAR2 := NULL,
     argument43          IN     VARCHAR2 := NULL,
     argument44          IN     VARCHAR2 := NULL,
     argument45          IN     VARCHAR2 := NULL,
     argument46          IN     VARCHAR2 := NULL,
     argument47          IN     VARCHAR2 := NULL,
     argument48          IN     VARCHAR2 := NULL,
     argument49          IN     VARCHAR2 := NULL,
     argument50          IN     VARCHAR2 := NULL,
     argument51          IN     VARCHAR2 := NULL,
     argument52          IN     VARCHAR2 := NULL,
     argument53          IN     VARCHAR2 := NULL,
     argument54          IN     VARCHAR2 := NULL,
     argument55          IN     VARCHAR2 := NULL,
     argument56          IN     VARCHAR2 := NULL,
     argument57          IN     VARCHAR2 := NULL,
     argument58          IN     VARCHAR2 := NULL,
     argument59          IN     VARCHAR2 := NULL,
     argument60          IN     VARCHAR2 := NULL,
     argument61          IN     VARCHAR2 := NULL,
     argument62          IN     VARCHAR2 := NULL,
     argument63          IN     VARCHAR2 := NULL,
     argument64          IN     VARCHAR2 := NULL,
     argument65          IN     VARCHAR2 := NULL,
     argument66          IN     VARCHAR2 := NULL,
     argument67          IN     VARCHAR2 := NULL,
     argument68          IN     VARCHAR2 := NULL,
     argument69          IN     VARCHAR2 := NULL,
     argument70          IN     VARCHAR2 := NULL,
     argument71          IN     VARCHAR2 := NULL,
     argument72          IN     VARCHAR2 := NULL,
     argument73          IN     VARCHAR2 := NULL,
     argument74          IN     VARCHAR2 := NULL,
     argument75          IN     VARCHAR2 := NULL,
     argument76          IN     VARCHAR2 := NULL,
     argument77          IN     VARCHAR2 := NULL,
     argument78          IN     VARCHAR2 := NULL,
     argument79          IN     VARCHAR2 := NULL,
     argument80          IN     VARCHAR2 := NULL,
     argument81          IN     VARCHAR2 := NULL,
     argument82          IN     VARCHAR2 := NULL,
     argument83          IN     VARCHAR2 := NULL,
     argument84          IN     VARCHAR2 := NULL,
     argument85          IN     VARCHAR2 := NULL,
     argument86          IN     VARCHAR2 := NULL,
     argument87          IN     VARCHAR2 := NULL,
     argument88          IN     VARCHAR2 := NULL,
     argument89          IN     VARCHAR2 := NULL,
     argument90          IN     VARCHAR2 := NULL,
     argument91          IN     VARCHAR2 := NULL,
     argument92          IN     VARCHAR2 := NULL,
     argument93          IN     VARCHAR2 := NULL,
     argument94          IN     VARCHAR2 := NULL,
     argument95          IN     VARCHAR2 := NULL,
     argument96          IN     VARCHAR2 := NULL,
     argument97          IN     VARCHAR2 := NULL,
     argument98          IN     VARCHAR2 := NULL,
     argument99          IN     VARCHAR2 := NULL,
     argument100         IN     VARCHAR2 := NULL);


END FARX_C_MCR;

/
