--------------------------------------------------------
--  DDL for Package Body IEC_RLCTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RLCTRL_PVT" AS
/* $Header: IECRCPVB.pls 115.0.1157.1 2002/03/14 08:56:24 pkm ship        $ */

TYPE BULK_COLLECT_COLUMN_N IS TABLE OF NUMBER(15);

PROCEDURE MAKE_LIST_ENTRIES_AVAILABLE ( P_LIST_HEADER_ID	IN	NUMBER
                                      , P_DNU_REASON_CODE	IN	NUMBER
                                      , P_COMMIT                IN      BOOLEAN
                                      , X_RETURN_STATUS		OUT	VARCHAR2)
IS

   L_LIST_ENTRY_IDS BULK_COLLECT_COLUMN_N := BULK_COLLECT_COLUMN_N();

BEGIN

   SAVEPOINT SP1;

   X_RETURN_STATUS := 'S';

   IF P_DNU_REASON_CODE IS NOT NULL THEN

      SELECT LIST_ENTRY_ID
      BULK COLLECT INTO L_LIST_ENTRY_IDS
      FROM AMS_LIST_ENTRIES
      WHERE LIST_HEADER_ID = P_LIST_HEADER_ID AND DO_NOT_USE_FLAG = 'Y' AND DO_NOT_USE_REASON = P_DNU_REASON_CODE;

   ELSE

      SELECT LIST_ENTRY_ID
      BULK COLLECT INTO L_LIST_ENTRY_IDS
      FROM AMS_LIST_ENTRIES
      WHERE LIST_HEADER_ID = P_LIST_HEADER_ID AND DO_NOT_USE_FLAG = 'Y';

   END IF;

   IF L_LIST_ENTRY_IDS IS NOT NULL AND L_LIST_ENTRY_IDS.COUNT > 0 THEN

      FORALL I IN L_LIST_ENTRY_IDS.FIRST..L_LIST_ENTRY_IDS.LAST
         UPDATE AMS_LIST_ENTRIES
         SET DO_NOT_USE_FLAG = 'N'
         WHERE LIST_ENTRY_ID = L_LIST_ENTRY_IDS(I);

      FORALL I IN L_LIST_ENTRY_IDS.FIRST..L_LIST_ENTRY_IDS.LAST
         UPDATE IEC_G_RETURN_ENTRIES
         SET DO_NOT_USE_FLAG = 'N'
         WHERE LIST_ENTRY_ID = L_LIST_ENTRY_IDS(I);

   END IF;

   IF P_COMMIT THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO SP1;
      X_RETURN_STATUS := 'E';

END MAKE_LIST_ENTRIES_AVAILABLE;


END IEC_RLCTRL_PVT;

/
