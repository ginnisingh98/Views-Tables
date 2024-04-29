--------------------------------------------------------
--  DDL for Package Body IEX_LOAD_FILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_LOAD_FILE_PVT" AS
/* $Header: iexvfilb.pls 120.0 2004/01/24 03:26:01 appldev noship $ */


PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

Procedure UPDATE_AMV_ATTACH1
           (p_file_id             IN NUMBER )
IS
   l_attachment_id         NUMBER;

BEGIN

   l_attachment_id := 2001;

   Update jtf_amv_attachments
      set file_id = p_file_id
    where attachment_id = l_attachment_id
     and application_id = 695;

   UPDATE_FILE_NAME(p_file_id);

END UPDATE_AMV_ATTACH1;


Procedure UPDATE_AMV_ATTACH2
           (p_file_id             IN NUMBER )
IS
   l_attachment_id         NUMBER;

BEGIN

   l_attachment_id := 2002;

   Update jtf_amv_attachments
      set file_id = p_file_id
    where attachment_id = l_attachment_id
     and application_id = 695;

   UPDATE_FILE_NAME(p_file_id);

END UPDATE_AMV_ATTACH2;


Procedure UPDATE_AMV_ATTACH3
           (p_file_id             IN NUMBER )
IS
   l_attachment_id         NUMBER;

BEGIN

   l_attachment_id := 2003;

   Update jtf_amv_attachments
      set file_id = p_file_id
    where attachment_id = l_attachment_id
     and application_id = 695;

   UPDATE_FILE_NAME(p_file_id);

END UPDATE_AMV_ATTACH3;


Procedure UPDATE_AMV_ATTACH4
           (p_file_id             IN NUMBER )
IS
   l_attachment_id         NUMBER;

BEGIN

   l_attachment_id := 2004;

   Update jtf_amv_attachments
      set file_id = p_file_id
    where attachment_id = l_attachment_id
     and application_id = 695;

   UPDATE_FILE_NAME(p_file_id);

END UPDATE_AMV_ATTACH4;


Procedure UPDATE_AMV_ATTACH5
           (p_file_id             IN NUMBER )
IS
   l_attachment_id         NUMBER;

BEGIN

   l_attachment_id := 2005;

   Update jtf_amv_attachments
      set file_id = p_file_id
    where attachment_id = l_attachment_id
     and application_id = 695;

   UPDATE_FILE_NAME(p_file_id);

END UPDATE_AMV_ATTACH5;


Procedure UPDATE_FILE_NAME
           (p_file_id             IN NUMBER )
IS
  CURSOR C_GET_FileName (IN_ID NUMBER) IS
    SELECT substr(file_name, instr(file_name, '/IEXFm')+1, length(file_name)-instr(file_name,'/IEXFm') )
      FROM fnd_lobs
     WHERE file_id = IN_ID;
   --
   l_file_name        VARCHAR2(1000);

BEGIN

   OPEN C_Get_FileName (p_file_id);
  FETCH C_Get_FileName INTO l_file_name;

  IF (C_Get_FileName%NOTFOUND)
  THEN
      null;
  END IF;
  CLOSE C_GET_FileName;

   Update fnd_lobs
      set file_name = l_file_name
    where file_id = p_file_id;

END UPDATE_FILE_NAME;


END IEX_LOAD_FILE_PVT;

/
