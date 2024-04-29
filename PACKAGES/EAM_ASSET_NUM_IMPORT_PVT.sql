--------------------------------------------------------
--  DDL for Package EAM_ASSET_NUM_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_NUM_IMPORT_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVANIS.pls 115.6 2002/11/20 19:02:31 aan ship $*/

   -- Start of comments
   -- API name : Load_Asset_Number
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters :
   -- IN       p_batch_id         IN      NUMBER Required,
   --          p_purge_option     IN      VARCHAR2 Optional Default = 'N'
   -- OUT      ERRBUF OUT VARCHAR2,
   --          RETCODE OUT VARCHAR2
   --
   -- Version  Initial version    1.0     Anirban Dey
   --
   -- Notes    : This public API imports asset numbers into
   --            MTL_SERIAL_NUMBERS
   --
   -- End of comments

Error               EXCEPTION;
Current_Error_Code  Varchar2(9) := NULL;
Curr_Error          Varchar2(9) := NULL;

PROCEDURE Load_Asset_Numbers
    (ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY VARCHAR2,
     p_batch_id IN NUMBER,
     p_purge_option IN VARCHAR2 := 'N'
     );

FUNCTION Import_Asset_Numbers
    (
    p_batch_id                  IN      NUMBER,
    p_purge_option              IN      VARCHAR2 := 'N'
    )	RETURN Number;


END EAM_ASSET_NUM_IMPORT_PVT;

 

/
