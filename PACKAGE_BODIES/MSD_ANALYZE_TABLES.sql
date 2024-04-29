--------------------------------------------------------
--  DDL for Package Body MSD_ANALYZE_TABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_ANALYZE_TABLES" AS
    /* $Header: msdaztbb.pls 115.4 2004/08/03 08:27:54 sudekuma ship $ */

   l_table_type     table_type_list;

PROCEDURE analyze_table (
                        p_table_name        IN VARCHAR2,
                        p_type              IN NUMBER) IS


     l_messg  varchar(100);

PROCEDURE Init is

    begin

        /* Level Values Staging  */

        l_table_type(1).table_name   := 'MSD_ST_LEVEL_VALUES';
        l_table_type(1).table_type   := 1;

        l_table_type(2).table_name   := 'MSD_ST_LEVEL_ASSOCIATIONS';
        l_table_type(2).table_type   := 1;

        l_table_type(3).table_name   := 'MSD_ST_ITEM_LIST_PRICE';
        l_table_type(3).table_type   := 1;

        l_table_type(28).table_name  := 'MSD_ST_ITEM_RELATIONSHIPS';
        l_table_type(28).table_type  := 1;

        /* Level Values Fact  */

        l_table_type(4).table_name   := 'MSD_LEVEL_VALUES';
        l_table_type(4).table_type   := 2;

        l_table_type(5).table_name   := 'MSD_LEVEL_ASSOCIATIONS';
        l_table_type(5).table_type   := 2;

        l_table_type(6).table_name   := 'MSD_ITEM_LIST_PRICE';
        l_table_type(6).table_type   := 2;

        l_table_type(25).table_name   := 'MSD_ORG_CALENDARS';
        l_table_type(25).table_type   := 2;

        l_table_type(26).table_name   := 'MSD_LEVEL_ORG_ASSCNS';
        l_table_type(26).table_type   := 2;

        l_table_type(29).table_name   := 'MSD_ITEM_RELATIONSHIPS';
        l_table_type(29).table_type   := 2;

        /* All Fact  */

        l_table_type(7).table_name   := 'MSD_BOOKING_DATA';
        l_table_type(7).table_type   := 3;

        l_table_type(8).table_name   := 'MSD_SHIPMENT_DATA';
        l_table_type(8).table_type   := 3;

        l_table_type(9).table_name   := 'MSD_CURRENCY_CONVERSIONS';
        l_table_type(9).table_type   := 3;

        l_table_type(10).table_name   := 'MSD_MFG_FORECAST';
        l_table_type(10).table_type   := 3;

        l_table_type(11).table_name   := 'MSD_TIME';
        l_table_type(11).table_type   := 3;

        l_table_type(12).table_name   := 'MSD_UOM_CONVERSIONS';
        l_table_type(12).table_type   := 3;

        l_table_type(13).table_name   := 'MSD_PRICE_LIST';
        l_table_type(13).table_type   := 3;

        /* Added 09/17/2002 Pinamati */
        l_table_type(24).table_name   := 'MSD_DP_SCENARIO_ENTRIES';
        l_table_type(24).table_type   := 3;
        /* End Addition*/

        /* All Staging  */

        l_table_type(14).table_name   := 'MSD_ST_BOOKING_DATA';
        l_table_type(14).table_type   := 4;

        l_table_type(15).table_name   := 'MSD_ST_SHIPMENT_DATA';
        l_table_type(15).table_type   := 4;

        l_table_type(16).table_name   := 'MSD_ST_CURRENCY_CONVERSIONS';
        l_table_type(16).table_type   := 4;

        l_table_type(17).table_name   := 'MSD_ST_MFG_FORECAST';
        l_table_type(17).table_type   := 4;

        l_table_type(18).table_name   := 'MSD_ST_TIME';
        l_table_type(18).table_type   := 4;

        l_table_type(19).table_name   := 'MSD_ST_UOM_CONVERSIONS';
        l_table_type(19).table_type   := 4;

        l_table_type(20).table_name   := 'MSD_ST_PRICE_LIST';
        l_table_type(20).table_type   := 4;

        l_table_type(21).table_name   := 'MSD_ST_CS_DATA';
        l_table_type(21).table_type   := 4;

        /* Custom Stream Fact   */

        l_table_type(22).table_name   := 'MSD_CS_DATA';
        l_table_type(22).table_type   := 5;

        /* Custom Stream Staging   */

        l_table_type(23).table_name   := 'MSD_ST_CS_DATA';
        l_table_type(23).table_type   := 6;

        /* Demand Partition Tables */

        l_table_type(30).table_name   := 'MSD_LEVEL_VALUES_DS';
        l_table_type(30).table_type   := 7;

        l_table_type(27).table_name   := 'MSD_CS_DATA_DS';
        l_table_type(27).table_type   := 7;


    End;


Begin
    -- Initialize parameter array
    Init;

       for j IN l_table_type.FIRST..l_table_type.LAST LOOP
             if p_table_name is not null and p_table_name = l_table_type(j).table_name then
                l_messg := 'Analyzing table ' || p_table_name;
           --     dbms_output.put_line(l_messg);
                fnd_file.put_line(fnd_file.log, l_messg);
                fnd_stats.gather_table_stats('MSD', p_table_name, 10, 4);

             elsif p_type = l_table_type(j).table_type or p_type = 0 then

           /* 09/17/2002 - Changed spelling in message - Pinamati */
                l_messg := 'Analyzing table ' || l_table_type(j).table_name;
           --     dbms_output.put_line(l_messg);
                fnd_file.put_line(fnd_file.log, l_messg);
	        fnd_stats.gather_table_stats('MSD', l_table_type(j).table_name, 10, 4);
             end if;
       end loop;

END analyze_table;

END; -- package

/
