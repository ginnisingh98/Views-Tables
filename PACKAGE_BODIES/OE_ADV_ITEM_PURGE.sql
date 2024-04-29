--------------------------------------------------------
--  DDL for Package Body OE_ADV_ITEM_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ADV_ITEM_PURGE" AS
/* $Header: OEXADPRB.pls 120.0 2005/06/01 00:25:19 appldev noship $ */


--  Start of Comments
--  API name    Purge_Used_Sessions
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Purge_Used_Sessions  ( retcode OUT NOCOPY VARCHAR2,
				 errbuf OUT NOCOPY VARCHAR2 )
  IS

BEGIN

   delete from oe_selected_items
    where used_flag = 'Y';

   commit;

EXCEPTION

   WHEN OTHERS THEN
      oe_debug_pub.add( 'Error in deleting data from oe_selected_items '||sqlerrm);
      retcode := 2;
      errbuf := sqlerrm;

END PURGE_USED_SESSIONS;

END OE_ADV_ITEM_PURGE;

/
