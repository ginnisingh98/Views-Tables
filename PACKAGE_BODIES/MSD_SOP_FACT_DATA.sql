--------------------------------------------------------
--  DDL for Package Body MSD_SOP_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SOP_FACT_DATA" AS
/* $Header: msdsfdcb.pls 120.3 2005/12/08 22:27:44 sjagathe noship $ */

/* Constants added for Bug# 4308790--------*/
C_FROM_DATE       constant     varchar2(100) := '1000/01/01 00:00:00';
C_TO_DATE       constant      varchar2(100)  := '4000/12/31 00:00:00';

SYS_YES               CONSTANT NUMBER := 1;    /* Bug# 4615390 ISO */
SYS_NO                CONSTANT NUMBER := 2;    /* Bug# 4615390 ISO */

PROCEDURE sop_fact_data_collect(   errbuf              OUT NOCOPY VARCHAR2,
                                   retcode             OUT NOCOPY VARCHAR2,
                                   p_instance_id       IN NUMBER,
                                   p_date_from	       IN VARCHAR2,
                                   p_date_to           IN VARCHAR2,
                                /* p_booking_data      IN NUMBER,
                                   p_shipment_data     IN NUMBER,             Bug# 4867205*/
                                   p_total_backlog     IN NUMBER,
                                   p_pastdue_backlog   IN NUMBER,
                                   p_onhand_inventory  IN NUMBER,
                                   p_production_plan   IN NUMBER,
                                   p_actual_production IN NUMBER
                                       ) is



cursor get_cs_defn_id_c1(l_cs_name IN Varchar2) IS
  select cs_definition_id
  from msd_cs_definitions
  where name = l_cs_name;

l_cs_name     cs_name_list;
l_date_from   varchar2(30);
l_date_to   varchar2(30);
l_onhand_date_to  varchar2(30);

l_cs_definition_id number;
l_cs_name_desc varchar2(80);

i number;
l_req_num number;
l_request_id number;
x_date_from varchar2(100);
x_date_to varchar2(100);

BEGIN
fnd_file.put_line(fnd_file.log, 'Launching SOP Fact Data Collect');

 /* Bug # 4308790 ---- Always populate date range even though the range is null.
            In case of null, we will use extremely small and large date
            for the from date and to date ........... Amitku*/

  x_date_from := nvl(p_date_from, C_FROM_DATE);
  x_date_to := nvl(p_date_to, C_TO_DATE);

    l_onhand_date_to := null;

/* Create list of SOP streams need to be colelcted */

/* Bug# 4867205 - Booking and Shipment Data will be collected separately
   if p_booking_data = 1 then
      l_request_id := 0;
      l_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                             'MSD',
                             'MSDCBD', -- Booking Data  collect program called
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- TRUE,
                             p_instance_id,  -- Instance Id
                             x_date_from,  -- start date
                             x_date_to,    -- End Date
                             SYS_NO        -- Bug# 4615390: Do not collect ISOs
                             );

       COMMIT;

       IF l_request_id = 0 THEN
           fnd_file.put_line(fnd_file.log, 'Booking Data Collect Launch Failed');
       ELSE
           fnd_file.put_line(fnd_file.log, 'Booking Data collect Request Id: '||l_request_id);
       END IF;

   end if;


   if p_shipment_data = 1 then

      l_request_id := 0;
      l_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                             'MSD',
                             'MSDCSD', -- Shipment Data collect program called
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- TRUE,
                             p_instance_id,  -- Instance Id
                             x_date_from,  -- start date
                             x_date_to,    -- End Date
                             SYS_NO        -- Bug# 4615390: Do not collect ISOs
                             );

       COMMIT;

       IF l_request_id = 0 THEN
           fnd_file.put_line(fnd_file.log, 'Shipment Data Collect Launch Failed');
       ELSE
           fnd_file.put_line(fnd_file.log, 'Shipment Data collect Request Id: '||l_request_id);
       END IF;

   end if;

*/

   i := 0;
   if p_total_backlog = 1 then

       i:= i+1;
       l_cs_name(i).cs_name := 'MSD_TOTAL_BACKLOG';

   end if;

   if p_pastdue_backlog = 1 then

       i:= i+1;
       l_cs_name(i).cs_name := 'MSD_PASTDUE_BACKLOG';

   end if;

   if p_production_plan = 1 then

       i:= i+1;
       l_cs_name(i).cs_name := 'MSD_PRODUCTION_PLAN';

   end if;

   if p_actual_production = 1 then

       i:= i+1;
       l_cs_name(i).cs_name := 'MSD_ACTUAL_PRODUCTION';

   end if;

   if p_onhand_inventory = 1 then

       i:= i+1;
       l_cs_name(i).cs_name := 'MSD_ONHAND_INVENTORY';

       if to_date(x_date_to, 'YYYY/MM/DD HH24:MI:SS') >= sysdate then

          l_onhand_date_to := to_char(trunc(sysdate -1), 'YYYYMMDD');

       end if;

   end if;

   l_date_from := to_char(trunc(to_date(x_date_from, 'YYYY/MM/DD HH24:MI:SS')), 'YYYYMMDD');
   l_date_to := to_char(trunc(to_date(x_date_to, 'YYYY/MM/DD HH24:MI:SS')), 'YYYYMMDD');


/* Check If any SOP streams need to be collected */

   IF l_cs_name.exists(1) THEN

      FOR j IN l_cs_name.FIRST..l_cs_name.LAST LOOP

/* Get SOP stream defintion id */
        l_cs_definition_id := null;

        open get_cs_defn_id_c1(l_cs_name(j).cs_name);
        fetch get_cs_defn_id_c1 into l_cs_definition_id;
        close get_cs_defn_id_c1;

        if l_cs_definition_id is not null then

           l_cs_name_desc := null;

           select description
           into l_cs_name_desc
           from msd_cs_definitions
           where cs_definition_id = l_cs_definition_id;

           /* Get Collection request id */
           l_req_num := 0;

           select MSD_CS_COLL_REQUEST_S.nextval
           into l_req_num
           from dual;

/* Call DP CS Collection program */

            l_request_id := 0;
            if l_onhand_date_to is not null then

               l_request_id := fnd_request.submit_request('MSD', 'MSDCSCL', NULL, NULL,FALSE,
                                       'C', 'Y',
                                        l_cs_definition_id,
                                        NULL,
                                        'Y',
                                        p_instance_id,
                                        l_date_from,
                                        l_onhand_date_to,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        l_req_num );

               l_onhand_date_to := null;

            else

               l_request_id := fnd_request.submit_request('MSD', 'MSDCSCL', NULL, NULL,FALSE,
                                       'C', 'Y',
                                        l_cs_definition_id,
                                        NULL,
                                        'Y',
                                        p_instance_id,
                                        l_date_from,
                                        l_date_to,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        l_req_num );

            end if;

            COMMIT;

            IF l_request_id = 0 THEN
               fnd_file.put_line(fnd_file.log, l_cs_name_desc||' Data Collect Launch Failed');
            ELSE
               fnd_file.put_line(fnd_file.log, l_cs_name_desc||' Data collect Request Id: '||l_request_id);
            END IF;

          end if;
      end loop;
   end if;

   EXCEPTION
     WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, 'Error in SOP Fact Data Collect Launch');
        fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
        retcode := -1;
        raise;
end ;

PROCEDURE sop_fact_data_pull(errbuf              OUT NOCOPY VARCHAR2,
                             retcode             OUT NOCOPY VARCHAR2
                             ) is

cursor get_cs_defn_id_c2 IS
  select cs_definition_id
  from msd_cs_definitions
  where name in ('MSD_TOTAL_BACKLOG', 'MSD_PASTDUE_BACKLOG', 'MSD_PRODUCTION_PLAN',
                 'MSD_ACTUAL_PRODUCTION', 'MSD_ONHAND_INVENTORY');

cursor get_cs_name_c2 (l_cs_definition_id IN number) IS
  select name
  from msd_cs_definitions
  where cs_definition_id = l_cs_definition_id;

l_cs_id cs_id_list;
l_req_num number;
l_cs_name varchar(30);
l_cs_name_desc varchar(80);
l_request_id number;

BEGIN
   /* Pull SOP Fact data from staging table to fact table */
   fnd_file.put_line(fnd_file.log, 'Launching SOP Fact Data Pull');

/* Bug# 4867205 - Booking and Shipment Data will be collected separately

   -- Launch Booking Data Pull Process
   l_request_id := 0;
   l_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                            'MSD',
                            'MSDPBD', -- Booking Data Pull program called
                            NULL,  -- description
                            NULL,  -- start date
                            FALSE, -- TRUE
                            SYS_NO        -- Bug# 4615390: Do not collect ISOs
                           );
   COMMIT;

   IF l_request_id = 0 THEN
      fnd_file.put_line(fnd_file.log, 'Booking Data Pull Launch Failed');
   ELSE
      fnd_file.put_line(fnd_file.log, 'Booking Data Pull Request Id: '||l_request_id);
   END IF;

   -- Launch Shipment Data Pull Process
   l_request_id := 0;
   l_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                         'MSD',
                         'MSDPSD', -- Shipment Data Pull program called
                         NULL,  -- description
                         NULL,  -- start date
                         FALSE, -- TRUE
                         SYS_NO        -- Bug# 4615390: Do not collect ISOs
                       );

   COMMIT;

   IF l_request_id = 0 THEN
      fnd_file.put_line(fnd_file.log, 'Shipment Data Pull Launch Failed');
   ELSE
      fnd_file.put_line(fnd_file.log, 'Shipment Data Pull Request Id: '||l_request_id);
   END IF;

*/

   open get_cs_defn_id_c2;
   fetch get_cs_defn_id_c2 bulk collect into l_cs_id;
   close get_cs_defn_id_c2;

   IF l_cs_id.exists(1) THEN

      FOR j IN l_cs_id.FIRST..l_cs_id.LAST LOOP

          /* Get CS Name */
          l_cs_name := null;

          open get_cs_name_c2 (l_cs_id(j).cs_definition_id);
          fetch get_cs_name_c2 into l_cs_name;
          close get_cs_name_c2;

           l_cs_name_desc := null;

           select description
           into l_cs_name_desc
           from msd_cs_definitions
           where cs_definition_id = l_cs_id(j).cs_definition_id;

--          fnd_file.put_line(fnd_file.log, 'CS Name: '||l_cs_name);
--          fnd_file.put_line(fnd_file.log, 'CS Id: '||l_cs_id(j).cs_definition_id);

          select MSD_CS_COLL_REQUEST_S.nextval
          into l_req_num
          from dual;

          /* Call CS Data Pull program */

          l_request_id := 0;
          l_request_id := fnd_request.submit_request('MSD', 'MSDCSCL', NULL, NULL,FALSE,
                                       'P',
                                       'Y',
                                        l_cs_id(j).cs_definition_id,
                                        null,
                                        'Y',
                                        null,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        l_req_num );

          IF l_request_id = 0 THEN
             fnd_file.put_line(fnd_file.log, l_cs_name_desc||' Data Pull Launch Failed');
          ELSE
             fnd_file.put_line(fnd_file.log, l_cs_name_desc||' Data Pull Request Id: '||l_request_id);
          END IF;

        COMMIT;

      end loop;

   end if;

   EXCEPTION
     WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log, 'Error in SOP Fact Data Pull Launch');
        fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
        retcode := -1;
        raise;
end ;

END MSD_SOP_FACT_DATA;

/
