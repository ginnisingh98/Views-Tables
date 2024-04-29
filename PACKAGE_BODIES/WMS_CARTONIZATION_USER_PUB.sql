--------------------------------------------------------
--  DDL for Package Body WMS_CARTONIZATION_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CARTONIZATION_USER_PUB" AS
/* $Header: WMSCRTUB.pls 120.2 2008/04/16 19:24:38 rsagar noship $*/

 PROCEDURE log_event(
                      p_message VARCHAR2)
  IS

     l_module VARCHAR2(255);
     l_mesg VARCHAR2(255);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN

   l_module := 'wms.plsql.' || 'wms_cartnzn_pub' || '.' || 'cartonization';

   --inv_pick_wave_pick_confirm_pub.TraceLog(err_msg => p_message,
   --                                      module => 'WMS_CARTNZN_PUB'
   --                                      );


   l_mesg := to_char(sysdate, 'YYYY-MM-DD HH:DD:SS') || p_message;

   IF (l_debug = 1) THEN
      -- dbms_output.put_line(l_mesg);
      inv_trx_util_pub.trace(l_mesg, 'WMS_CARTNZN_PUB');
   END IF;


 END log_event;

   PROCEDURE cartonize
                  ( x_return_status    OUT NOCOPY VARCHAR2,
                    x_msg_count        OUT NOCOPY NUMBER,
                    x_msg_data         OUT NOCOPY VARCHAR2,
                    x_task_table       OUT NOCOPY mmtt_type,
                    p_organization_id  IN  NUMBER,
                    p_task_table       IN  mmtt_type
                    )
   IS
      l_return_status VARCHAR2(1) := 'E';
      l_to_lpn_id  NUMBER;
      l_process_id NUMBER;
      l_to_lpn  VARCHAR2(400);
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2(5000);
   BEGIN
        log_event(' Inside customer code WMS_CARTONIZATION_USER_PUB.CARTONIZE()');
         -- Customer code.

         log_event('p_task_table.COUNT : '|| p_task_table.COUNT);

/*         FOR i IN p_task_table.FIRST .. p_task_table.LAST LOOP
            x_task_table(i) := p_task_table(i);
         END LOOP;

        log_event('x_task_table := p_task_table');

         FOR i IN x_task_table.FIRST .. x_task_table.LAST
         LOOP

        log_event(' Inside for loop');

         WMS_CONTAINER_PUB.GENERATE_LPN
           (p_api_version  => 1.0,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            p_organization_id => p_organization_id,
            p_lpn_out => l_to_lpn,
            p_lpn_id_out => l_to_lpn_id,
            p_process_id => l_process_id,
            p_validation_level => FND_API.G_VALID_LEVEL_NONE);

            log_event(' Generated LPN_ID :'||l_to_lpn_id || ' LPN : '|| l_to_lpn);

            log_event(' Inside Loop i : '|| i);

            x_task_table(i).cartonization_id := l_to_lpn_id;
            x_task_table(i).container_item_id := 262907;

         END LOOP;


         FOR i IN x_task_table.FIRST .. x_task_table.LAST
         LOOP
            log_event(' Inside x_task_table Loop i : '|| i);
            log_event(' p_task_table(i).cartonization_id: '|| x_task_table(i).cartonization_id);
            log_event(' p_task_table(i).container_item_id: '|| x_task_table(i).container_item_id);
         END LOOP;

*/
         x_return_status := 'S';
EXCEPTION  -- Bug : 6962305
WHEN OTHERS THEN
   log_event('Unexpected Error in  WMS_CARTONIZATION_USER_PUB.CARTONIZE()');
   log_event('SQLERRM : ' || SQLERRM);
   log_event('SQLERRM : ' || SQLCODE);
   x_return_status := 'E';
END;

END WMS_CARTONIZATION_USER_PUB;

/
