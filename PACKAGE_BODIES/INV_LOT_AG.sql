--------------------------------------------------------
--  DDL for Package Body INV_LOT_AG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_AG" AS
/* $Header: INVLOTGB.pls 120.1 2005/06/11 08:31:34 appldev  $ */

/* Global constant holding package name */
G_PKG_NAME CONSTANT VARCHAR2(20) := 'INV_LOT_AG' ;


PROCEDURE update_lot_age( x_retcode        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                          ,x_errbuf        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                          ,p_age_for_expired_lots IN VARCHAR2
			) IS
    var_age_for_expired_lots varchar2(10);
    var_enabled number;
    var_age     number;

    cursor cur_lots_not_expired is
           select  ROWID,
                   INVENTORY_ITEM_ID,
                   ORGANIZATION_ID ,
                   CREATION_DATE,
                   EXPIRATION_DATE,
                   ORIGINATION_DATE
             from  mtl_lot_numbers
            where  trunc(expiration_date) <= nvl(origination_date,creation_date);

    cursor cur_lots_all is
           select  ROWID,
                   INVENTORY_ITEM_ID,
                   ORGANIZATION_ID ,
                   CREATION_DATE,
                   EXPIRATION_DATE,
                   ORIGINATION_DATE
             from  mtl_lot_numbers;

    lot_rec cur_lots_all%rowtype;

BEGIN


  -- Initialize the Message Stack
  FND_MSG_PUB.Initialize;

    var_age_for_expired_lots := p_age_for_expired_lots;
    --dbms_output.enable(1000000);

    if var_age_for_expired_lots = 'N'
    then
    -- Processing for All Lots
       open cur_lots_not_expired;
       loop
          fetch cur_lots_not_expired into lot_rec;
          exit when cur_lots_not_expired%notfound;

          -- Processing for context value AGE

          var_enabled := INV_LOT_SEL_ATTR.is_enabled_segment('Lot Attributes','AGE',
                                      lot_rec.organization_id,
                                      lot_rec.inventory_item_id
                                     );

          --dbms_output.put_line('con ' || var_enabled);

          if var_enabled > 0
          then

          -- Updater the AGE column.
             --dbms_output.put_line('before update');
             update mtl_lot_numbers
               set age= trunc(sysdate) - trunc(nvl(lot_rec.origination_date,lot_rec.creation_date))
              where rowid = lot_rec.rowid;
          end if;
       end loop;
       close cur_lots_not_expired;
    else
    -- Processing for  Lots not expired.
       open cur_lots_all;
       loop
          fetch cur_lots_all into lot_rec;
          exit when cur_lots_all%notfound;

          -- Processing for context value AGE

          var_enabled := INV_LOT_SEL_ATTR.is_enabled_segment('Lot Attributes','AGE',
                                      lot_rec.organization_id,
                                      lot_rec.inventory_item_id
                                     );

          --dbms_output.put_line('con ' || var_enabled);

          if var_enabled > 0
          then
          -- Updater the AGE column.
             --dbms_output.put_line('before update');
             update mtl_lot_numbers
               set age= trunc(sysdate) - trunc(nvl(lot_rec.origination_date,lot_rec.creation_date))
              where rowid = lot_rec.rowid;
          end if;
       end loop;
       close cur_lots_all;
    end if;

COMMIT;
x_errbuf  := NULL;
x_retcode := 0;

Exception
When others then
   IF
    FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                          , 'Update Age for Lot Attributes '
                          );
   END IF;

  x_errbuf  := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
  x_retcode := 2;
  RAISE;

END update_lot_age;

END INV_LOT_AG;

/
