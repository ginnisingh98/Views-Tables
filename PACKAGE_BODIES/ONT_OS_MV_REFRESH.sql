--------------------------------------------------------
--  DDL for Package Body ONT_OS_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OS_MV_REFRESH" AS
/* $Header: ontmvreb.pls 120.1 2006/03/29 16:54:46 spooruli noship $ */

PROCEDURE do_refresh(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2,

	p_mv_name			IN	VARCHAR2
);

PROCEDURE refresh_booked_orders(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2

) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
null;
/*	do_refresh(errbuf, retcode, 'ONT_BOOKED_ORDERS_MV');*/
END;


PROCEDURE refresh_shipped_orders(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2

) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
null;
/*
	do_refresh(errbuf, retcode, 'ONT_SHIPPED_ORDERS_MV');
*/
END;

PROCEDURE refresh_summary_mv(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2

) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
null;
/*
	do_refresh(errbuf, retcode, 'ONT_OS_SUMMARY_MV');
*/
END;

PROCEDURE do_refresh(
errbuf OUT NOCOPY VARCHAR2,

retcode OUT NOCOPY VARCHAR2,

        p_mv_name                 IN      VARCHAR2
) IS
        l_rewrite_enabled       VARCHAR2(1);
	l_owner			VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
null;
/*
        select REWRITE_ENABLED
        INTO l_rewrite_enabled
        from dba_mview_analysis where mview_name= p_mv_name;

--	select distinct owner into l_owner from all_objects where object_name = p_mv_name;

        IF  l_rewrite_enabled = 'N'
          THEN

                dbms_mview.refresh(p_mv_name, 'A', '', TRUE, FALSE, 0,0,0, TRUE);

        END IF;
*/
EXCEPTION
      WHEN NO_DATA_FOUND THEN
      null;
 /*       Errbuf := p_mv_name||' Does Not Exist in Table dba_mview_analysis...Going Ahead with the refresh';
        dbms_mview.refresh(p_mv_name, 'A', '', TRUE, FALSE, 0,0,0, TRUE);*/
      WHEN OTHERS THEN
     null;
/*
        Errbuf := fnd_message.get||'     '||SQLERRM;
        Retcode := 2;*/
END;


END;

/
