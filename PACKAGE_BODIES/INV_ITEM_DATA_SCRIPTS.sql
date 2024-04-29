--------------------------------------------------------
--  DDL for Package Body INV_ITEM_DATA_SCRIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_DATA_SCRIPTS" AS
/* $Header: INVIDSEB.pls 120.0.12010000.2 2010/03/23 15:20:16 kjonnala noship $ */

G_ERROR            CONSTANT  NUMBER  :=  2;


/* Procedure to modify internal_ordered_flag, internal_order_enabled flag and shippable flag.
   This datafix was originally given through bug 7572178 (datafix) and was necessiated
   due to the functional change introduced through bug 5533216 */
PROCEDURE proc_io_shippable_flags(
              errbuf  OUT NOCOPY VARCHAR2,
              retcode OUT NOCOPY NUMBER)
IS

l_sql_stmt_num NUMBER;

BEGIN
FND_FILE.put_line (FND_FILE.log, 'Entered procedure proc_io_shippable_flags ');

   l_sql_stmt_num := 1;
     UPDATE MTL_SYSTEM_ITEMS_B
      SET   INTERNAL_ORDER_ENABLED_FLAG ='N'
      WHERE INTERNAL_ORDER_ENABLED_FLAG ='Y'
      AND   INTERNAL_ORDER_FLAG ='N';

   l_sql_stmt_num := 2;
    UPDATE MTL_SYSTEM_ITEMS_B
     SET    INTERNAL_ORDER_ENABLED_FLAG ='N',
            INTERNAL_ORDER_FLAG ='N'
     WHERE  INTERNAL_ORDER_FLAG ='Y'
     AND    NVL(CONTRACT_ITEM_TYPE_CODE, 'SUBSCRIPTION') IN
            ('WARRANTY','SERVICE','USAGE');

  l_sql_stmt_num := 3;
    UPDATE MTL_SYSTEM_ITEMS_B
     SET    SHIPPABLE_ITEM_FLAG ='Y'
     WHERE  INTERNAL_ORDER_FLAG ='Y'
     AND    SHIPPABLE_ITEM_FLAG ='N'
     AND    NVL(CONTRACT_ITEM_TYPE_CODE, 'SUBSCRIPTION') NOT IN
                ('WARRANTY','SERVICE','USAGE');

FND_FILE.put_line (FND_FILE.log, 'End of procedure proc_io_shippable_flags ');

EXCEPTION
WHEN OTHERS THEN
         FND_FILE.put_line (FND_FILE.log, 'Exception occured during proc_io_shippable_flags ');
         FND_FILE.put_line (FND_FILE.log, 'while executing sql statement '||l_sql_stmt_num);
         FND_FILE.put_line (FND_FILE.log, SQLERRM);
         errbuf  := SQLERRM;
         retcode := G_ERROR;
END proc_io_shippable_flags;


/* Main procedure that gets called from the concurrent program
   'Items Data Scripts Execution' (INVIDSEP)*/

PROCEDURE run_data_scripts(
              errbuf  OUT NOCOPY VARCHAR2,
              retcode OUT NOCOPY NUMBER)
IS

BEGIN
FND_FILE.put_line (FND_FILE.log, 'Entered run_data_scripts of Items Data Scripts Execution Concurrent Program ');

/* call procedure proc_io_shippable_flags to correct the IO,IOE,shippable flags */
  proc_io_shippable_flags(errbuf,retcode);

FND_FILE.put_line (FND_FILE.log, 'End run_data_scripts of Items Data Scripts Execution Concurrent Program ');

EXCEPTION
WHEN OTHERS THEN
         FND_FILE.put_line (FND_FILE.log, 'Exception occured during Items Data Scripts Execution Concurrent Program ');
         FND_FILE.put_line (FND_FILE.log, SQLERRM);
         errbuf  := SQLERRM;
         retcode := G_ERROR;
END run_data_scripts;

END INV_ITEM_DATA_SCRIPTS;

/
