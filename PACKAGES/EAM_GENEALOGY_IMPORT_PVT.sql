--------------------------------------------------------
--  DDL for Package EAM_GENEALOGY_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_GENEALOGY_IMPORT_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVGEIS.pls 115.5 2002/11/20 19:29:21 aan ship $*/

   -- Start of comments
   -- API name : Load_Genalogy
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters :
   -- IN       p_batch_id         IN      NUMBER Required,
   --          p_purge_option     IN      VARCHAR2 Optional Default = 'N'
   -- OUT      ERRBUF OUT VARCHAR2,
   --          RETCODE OUT VARCHAR2
   --
   -- Version  Initial version    1.0     Kenichi Nagumo
   --
   -- Notes    : This public API imports asset genealogy into
   --            MTL_OBJECT_GENEALOGY
   --
   -- End of comments

Error               EXCEPTION;
Current_Error_Code  Varchar2(9) := NULL;
Curr_Error          Varchar2(9) := NULL;

PROCEDURE Load_Genealogy
    (ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY VARCHAR2,
     p_batch_id IN NUMBER,
     p_purge_option IN VARCHAR2 := 'N'
     );

FUNCTION Import_Genealogy
    (
    p_batch_id                  IN      NUMBER,
    p_purge_option              IN      VARCHAR2 := 'N'
    )	RETURN Number;


END EAM_GENEALOGY_IMPORT_PVT;

 

/
