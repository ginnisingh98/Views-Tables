--------------------------------------------------------
--  DDL for Package Body CS_SR_FUL_AMV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_FUL_AMV_PKG" as
/* $Header: cssruplb.pls 115.3 2001/04/30 11:48:31 pkm ship        $ */

-- ------------------------------------------------------
-- Update jtf_amv_attachment tables
-- ------------------------------------------------------
  PROCEDURE Update_AMV(p_file_id in Number)
  IS

  BEGIN
      UPDATE JTF_AMV_ATTACHMENTS
	    SET FILE_ID = p_file_id
      WHERE ATTACHMENT_USED_BY_ID = 1000;

      UPDATE FND_LOBS
        SET FILE_NAME = 'SRseed.html'
     WHERE  FILE_ID = p_file_id;

      COMMIT WORK;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          null;
   -- message
    WHEN OTHERS THEN
	    null;
   -- message

  END Update_AMV;

END CS_SR_FUL_AMV_PKG;

/
