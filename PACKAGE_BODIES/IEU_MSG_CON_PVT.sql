--------------------------------------------------------
--  DDL for Package Body IEU_MSG_CON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_MSG_CON_PVT" AS
/* $Header: IEUVMSCB.pls 115.6 2004/05/03 18:02:58 pkumble ship $ */


PROCEDURE IEU_MSG_DEL_MESSAGES(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2, p_last_update_date in date) IS

l_message VARCHAR2(4000);

Begin

  delete from ieu_msg_messages
  where status_id = 5
  and ( to_date(trunc(last_update_date), 'dd-mm-rrrr') <= to_date(trunc(p_last_update_date), 'dd-mm-rrrr') );
  commit;

EXCEPTION
  WHEN OTHERS THEN
       errbuf := sqlerrm;
       retcode := 2;
       l_message := sqlcode || ' '||sqlerrm;
       FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);

end ieu_msg_del_messages;

end ieu_msg_con_pvt;

/
