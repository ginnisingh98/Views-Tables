--------------------------------------------------------
--  DDL for Package JTF_IH_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_IMPORT" AUTHID CURRENT_USER AS
/* $Header: JTFIHIMS.pls 115.13 2002/12/11 15:18:54 ialeshin ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_IMPORT';


    nCntTransRows  NUMBER := 1000; -- Number of rows for per transaction (available for Interactions
    pnSessionNo  NUMBER := 0;       -- Session Number for Import. Default value is 0
    excNoSessionNo  EXCEPTION;
    nNxtSessionNo NUMBER := 0;
    bTest       BOOLEAN := TRUE;    -- bTest OFF - if you need import only without testing of data.
    PROCEDURE GO_TEST;
    PROCEDURE GO_IMPORT(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2);

    NO_ACTIVITIES CONSTANT VARCHAR2(254) := 'Activities Not Found';
    ACTIVITIES_PROBLEMS CONSTANT VARCHAR2(254) := 'This Ineraction has activities problems';
    NO_MEDIAITEM CONSTANT VARCHAR2(254) := 'Media Items Not Found';
    NO_ACTMEDIAITEM CONSTANT VARCHAR2(254) := 'Media Items for Activities was Not Found';
    MEDIA_ITEM_EXISTS CONSTANT VARCHAR(254) := 'Media Item already exists in JTF_IH_MEDIA_ITEMS table';

    NOTCREATEDINTERACTION CONSTANT VARCHAR(254) := 'Interaction was not created';
    NOTCREATEDACTIVITY CONSTANT VARCHAR(254) := 'Activity was not created';
    NOTCREATEDMEDIAITEM CONSTANT VARCHAR(254) := 'Media_Items was not created';
    NOTCLOSEDINTERACTION CONSTANT VARCHAR(254) := 'Interactions was not closed';
END;


 

/
