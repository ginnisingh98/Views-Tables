--------------------------------------------------------
--  DDL for Package Body INV_UPDATE_ONHAND_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UPDATE_ONHAND_STATUS" AS
/*  $Header: INVONSUB.pls 120.4 2008/03/18 06:55:47 aambulka noship $*/

  G_PKG_NAME           CONSTANT VARCHAR2(30) := 'INV_UPDATE_ONHAND_STATUS';
  g_debug              NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  PROCEDURE print_debug(msg VARCHAR2) IS
  BEGIN
    IF (g_debug = 1) THEN
      INV_LOG_UTIL.TRACE(msg,g_pkg_name);
    END IF;
  END print_debug;


  PROCEDURE update_onhand_status(
                              x_errbuf            OUT NOCOPY VARCHAR2
                             ,x_retcode           OUT NOCOPY NUMBER
                             ,p_from_org_code     IN  VARCHAR2
                             ,p_to_org_code       IN  VARCHAR2
                             ,p_default_status    IN  VARCHAR2 )  IS

      l_ret BOOLEAN ;

      l_bulk_limit     NUMBER := 5000;

      TYPE rowidtab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
      rowid_list       rowidtab;

      TYPE orgidtab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      orgid_list       orgidtab;

      l_default_status_id NUMBER := -1;
      l_count NUMBER := 0;
      l_record_count NUMBER := 0;

      CURSOR c_moqd(org_id IN NUMBER, l_bulk_limit IN NUMBER) IS
      SELECT rowid  FROM mtl_onhand_quantities_detail moqd
      WHERE moqd.organization_id = org_id
      AND  moqd.status_id is NULL
      AND  rownum < l_bulk_limit
      AND EXISTS(
                   select 1 from mtl_system_items msi
                   WHERE moqd.inventory_item_id = msi.inventory_item_id
                   AND moqd.organization_id = msi.organization_id
                   AND msi.serial_number_control_code in (1,6)
                )
      ORDER BY subinventory_code
      FOR UPDATE NOWAIT ;

      CURSOR c_org_id (l_from_org_code IN VARCHAR2 ,l_to_org_code IN VARCHAR2) IS
      SELECT organization_id FROM mtl_parameters
      WHERE  organization_code BETWEEN l_from_org_code AND l_to_org_code ;


  BEGIN

    print_debug('From Organization Code = '|| p_from_org_code );
    print_debug('To Organization Code = '|| p_to_org_code );
    print_debug('Default Status Code  = '|| p_default_status );

    BEGIN
       orgid_list.DELETE;
       OPEN c_org_id(p_from_org_code,p_to_org_code);
       FETCH c_org_id bulk collect INTO orgid_list ;

       --FETCH c_org_id bulk collect INTO orgid_list LIMIT l_bulk_limit;
       IF (orgid_list.Count = 0) THEN
         print_debug('No organization selected for given range. Please choose valid range');
         l_ret := fnd_concurrent.set_completion_status('ERROR', 'Error');

         x_retcode  := 2;
         x_errbuf   := 'Error';
         RETURN ;
       END IF ;

    EXCEPTION
       WHEN OTHERS THEN
          print_debug('Error in getting organization ids');
          print_debug('Error :'||substr(sqlerrm, 1, 200));

          IF c_org_id%ISOPEN THEN
              CLOSE c_org_id;
          END IF;

          l_ret := fnd_concurrent.set_completion_status('ERROR', 'Error');

          x_retcode  := 2;
          x_errbuf   := 'Error';

          RETURN ;
    END ;

    -- Updating onhand_flag of individual material statuses
    BEGIN
       -- Initialize RETCODE
       x_retcode := 0;

       -- Updating onhand_flag of individual material statuses

       UPDATE mtl_material_statuses_b
          SET onhand_control = 1
          WHERE Nvl(onhand_control,2) <> 1;

    EXCEPTION
       WHEN OTHERS THEN
          print_debug('Error updating the material statues');
          print_debug('Error :'||substr(sqlerrm, 1, 200));

          l_ret := fnd_concurrent.set_completion_status('ERROR', 'Error');

          x_retcode  := 2;
          x_errbuf   := 'Error';
       RETURN ;
    END ;


    FOR  i IN orgid_list.first..orgid_list.last LOOP

      print_debug('Running for OrganizationId =' || orgid_list(i));

      SELECT  NVL(default_status_id, -1)
      INTO   l_default_status_id
      FROM   mtl_parameters
      WHERE  organization_id = orgid_list(i);

      IF (l_default_status_id = -1) THEN

         l_record_count := 0;

         LOOP
             rowid_list.DELETE;
             OPEN c_moqd(orgid_list(i),l_bulk_limit);
             EXIT WHEN c_moqd%notfound;

             FETCH c_moqd BULK COLLECT INTO rowid_list LIMIT l_bulk_limit;

             IF rowid_list.first IS NULL THEN
                print_debug('No more onhand records to be updated for orgid');
                EXIT;
             END IF;

             FORALL j in rowid_list.first..rowid_list.last
                UPDATE mtl_onhand_quantities_detail moqd
                   SET status_id = inv_material_status_grp.get_default_status_conc(moqd.organization_id,
                                                                                   moqd.inventory_item_id,
                                                                                   moqd.subinventory_code,
                                                                                   moqd.locator_id,
                                                                                   moqd.lot_number,
                                                                                   moqd.lpn_id)
                 WHERE  rowid = rowid_list(j);

                  l_record_count := l_record_count + SQL%ROWCOUNT;
                  COMMIT;
             CLOSE c_moqd;

         END LOOP;
         IF c_moqd%ISOPEN THEN
          CLOSE c_moqd;
         END IF;

         print_debug('Updated :'||l_record_count||' rows in MOQD for orgid = ' || orgid_list(i));

          --BEGIN
          SELECT  Count(1)
          INTO  l_count
          FROM  mtl_onhand_quantities_detail moqd, mtl_system_items_b msi
          WHERE moqd.inventory_item_id = msi.inventory_item_id
          AND moqd.organization_id = msi.organization_id
          AND moqd.organization_id = orgid_list(i)
          AND msi.serial_number_control_code in (1,6)
          AND moqd.status_id is null
          AND  rownum = 1;

          IF (l_count = 0) THEN

             UPDATE mtl_parameters
                SET  default_status_id = (SELECT  status_id
                                          FROM  mtl_material_statuses_vl
                                          WHERE status_code = p_default_status)
                WHERE  organization_id = orgid_list(i);
             print_debug('Updated Default Material Status at organization level for org: '|| orgid_list(i));
          ELSE
             print_debug('Some onhand records do not have status_id populated');
          END IF ;

      ELSE
          print_debug('Organization is already onhand status enabled');
      END IF;

    END LOOP;

    l_ret := fnd_concurrent.set_completion_status('NORMAL', 'Success');

    x_retcode  := 0;
    x_errbuf   := 'Success';

  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Error :'||substr(sqlerrm, 1, 200));

      IF c_moqd%ISOPEN THEN
          CLOSE c_moqd;
      END IF;

      l_ret := fnd_concurrent.set_completion_status('ERROR', 'Error');

      x_retcode  := 2;
      x_errbuf   := 'Error';

  END update_onhand_status;


END INV_UPDATE_ONHAND_STATUS ;

/
