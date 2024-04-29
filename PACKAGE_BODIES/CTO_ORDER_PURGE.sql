--------------------------------------------------------
--  DDL for Package Body CTO_ORDER_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_ORDER_PURGE" as
/* $Header: CTOPURGB.pls 120.1 2005/06/06 10:05:49 appldev  $ */
/*
 *=========================================================================*
 |                                                                         |
 | Copyright (c) 2001, Oracle Corporation, Redwood Shores, California, USA |
 |                           All rights reserved.                          |
 |                                                                         |
 *=========================================================================*
 |                                                                         |
 | NAME                                                                    |
 |            CTO ORDER PURGE package body                                 |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   PL/SQL package body containing the deletion routine  for              |
 |   purging the data in CTO tables which were inserted during             |
 |   creation of orders                                                    |
 | ARGUMENTS                                                               |
 |   Input :  Please see the individual function or procedure.             |
 |                                                                         |
 | HISTORY                                                                 |
 |   Date      Author   Comments                                           |
 | --------- -------- ---------------------------------------------------- |
 |  05/09/2001  kkonada  intial creation of body for cto table purge       |
 |   06/04/2001  kkonada  moving delete statement of bcod out of the       |
 |               condition, bcod can have data without any corresponding   |
 |               data in bcol
 |
 |  03/26/2004   bugfix#3524022
 |               Kkonada added code to delete data from bom_cto_model_orgs
 |               Refrence to bom_cto_src_orgs is changed to bom_cto_src_orgs_b
 |
 |
 |  04/05/2004  bugfix#3524022
 |              coorected bugfix.
 |              locked table BCMO before deletion
 |              removed having count(group_reference_id) > 1
 |              removed close cursor statements from excpetion block
 |
 | 04/05/2004   Need to revert delete from BCMO as part of order purge
 |              It is decided in todays meeting between Usha, renga, sushant
 |              and Kiran to remove the BCMO data at the time
 |              when the data is removed from match table bom_ato_configurations.
 |              Details of items which are matched and whose model CIB =3 are
 |               stored in BCMO
 |
 |07/13/2004    Kiran Konada
 |              bugfix#3763753
 |              remove pre-configure data inserted pre-11.5.10 from BCOL and BCSO_B
 |
 |
 |06/01/2005    Renga Kannan
 |              Added nocopy hint to all out parameters.
 |
 *=========================================================================*/
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);


PROCEDURE cto_purge_tables
          ( p_header_id       IN  NUMBER,
            x_error_msg       OUT NOCOPY VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2
          )

IS


      l_top_model_line_id bom_cto_order_lines.top_model_line_id%type;

      --flags to control process flow depending on existance of header_id
      bcol_flag_1 VARCHAR2(1) := 'Y';


      --dummy variable
      l_dummy number;
      l_row_deleted number;

      --cursor to lock bom_cto_order_lines
      CURSOR c_bcol IS
      SELECT header_id
      FROM bom_cto_order_lines
      WHERE header_id = p_header_id
      FOR UPDATE NOWAIT;

      --cursor to lock bom_cto_order_demand
      CURSOR c_bcod IS
      SELECT header_id
      FROM bom_cto_order_demand
      WHERE header_id = p_header_id
      FOR UPDATE NOWAIT;

      --cursor to lock bom_cto_src_orgs
      CURSOR c_b_src_org Is
      SELECT top_model_line_id
      FROM bom_cto_src_orgs_b --3524022
      WHERE top_model_line_id=l_top_model_line_id
      FOR UPDATE NOWAIT;


BEGIN

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('cto_purge_tables: ' || 'Entering CTO_ORDER_PURGE.cto_purge_tables :
                         header_id=> '||to_char(p_header_id),1);
       END IF;

       --to check if rows exists for header_id in cto tables
       BEGIN
           SELECT header_id
           INTO l_dummy
           FROM bom_cto_order_lines
           where header_id= p_header_id
           and rownum=1;
       EXCEPTION
           WHEN OTHERS THEN
               bcol_flag_1  := 'N';
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('cto_purge_tables: ' || 'No rows exist in CTO tables for header_id'||
                                p_header_id ,3);
               END IF;
       END;



       IF  bcol_flag_1 = 'Y' THEN

             --lock table bom_cto_order_lines
             OPEN c_bcol;

             CLOSE c_bcol;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('cto_purge_tables: ' || 'locked table bcol ',3);
             END IF;

             SELECT top_model_line_id
             INTO l_top_model_line_id
             FROM bom_cto_order_lines
             where header_id= p_header_id
             and rownum=1;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('cto_purge_tables: ' || 'select top_model_line_id for lock bom_cto_src_org',3);
             END IF;


             --lock table bom_cto_src_orgs
             OPEN  c_b_src_org;

             CLOSE  c_b_src_org;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('cto_purge_tables: ' || 'locked table b_cto_src_orgs ',3);
             END IF;


             --Delete data from tables

             DELETE FROM bom_cto_src_orgs_b  --3524022
             WHERE top_model_line_id=l_top_model_line_id;
             l_row_deleted :=sql%rowcount;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('cto_purge_tables: ' || 'deleted from bom_cto_src_orgs_b'||l_row_deleted,3);
             END IF;



             DELETE FROM bom_cto_order_lines
             WHERE header_id = p_header_id;
             l_row_deleted :=sql%rowcount;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('cto_purge_tables: ' || 'deleted from bom_cto_order_lines'||l_row_deleted,3);
             END IF;


     END IF;

      --lock table bom_cto_order_demand
      OPEN c_bcod;

      CLOSE c_bcod;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('cto_purge_tables: ' || 'locked table bcod ',3);
      END IF;

      DELETE FROM bom_cto_order_demand
      WHERE header_id = p_header_id;
      l_row_deleted :=sql%rowcount;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('cto_purge_tables: ' || 'deleted from bom_cto_order_demand'||l_row_deleted,3);
      END IF;

      --bugfix#3763753
      --Remove the pre-configure data from bcol and bcso_b
      --as they are not needed for any future use
      --this is only for data created pre-11.5.10(BUT this is coded in 11.5.10)
      --In 11.5.10 data is deleted at the end of pre-cfg process

      delete from bom_cto_order_lines
      where line_id < 0;
      l_row_deleted :=sql%rowcount;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('cto_purge_tables: ' || 'pre-cfg rows deleted from bom_cto_order_lines'||l_row_deleted,3);
      END IF;

      delete from bom_cto_src_orgs_b
      where line_id < 0;
      l_row_deleted :=sql%rowcount;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('cto_purge_tables: ' || 'pre-cfg rows deleted from bom_cto_src_orgs_b'||l_row_deleted,3);
      END IF;
      --end bugfix#3763753

      x_return_status :=  FND_API.G_RET_STS_SUCCESS;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('cto_purge_tables: ' || 'Exiting CTO_ORDER_PURGE.cto_purge_tables :
                             with '||x_return_status,1);
      END IF;


EXCEPTION
       WHEN OTHERS THEN
           x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
           x_error_msg := 'ORDPUR:bom cto tables'||substr(sqlerrm,1,200);
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('cto_purge_tables: ' || sqlerrm,1);

           	oe_debug_pub.add('cto_purge_tables: ' || 'Exiting CTO_ORDER_PURGE.cto_purge_tables : with '
                         ||x_return_status,1);
           END IF;



END cto_purge_tables ;
END CTO_ORDER_PURGE;


/
