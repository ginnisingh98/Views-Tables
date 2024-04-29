--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_FORM_ROUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_FORM_ROUTE" AS
/* $Header: IEUFOOB.pls 120.0 2005/06/02 15:51:20 appldev noship $ */

PROCEDURE ieu_uwq_form_obj         (    p_ieu_media_data  IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST default null,
                                        p_action_type   OUT NOCOPY number,
                                        p_action_name   OUT NOCOPY varchar2,
                                        p_action_param          OUT NOCOPY varchar2 ) IS

  l_name  varchar2(500);
  l_value varchar2(1996);
  l_type  varchar2(500);

  l_action_param1 varchar2(1996);
  l_action_param2 varchar2(1996);
  l_action_param3 varchar2(1996);
  l_action_param4 varchar2(500);

  max_length number := 0;
  P_ieu_media_data1 system.ieu_uwq_media_data_nst;

  l_block_mode  boolean;
  l_continuous_mode  boolean;

  BEGIN
       p_ieu_media_data1 := SYSTEM.IEU_UWQ_MEDIA_DATA_NST();

       l_block_mode := FALSE;
       l_continuous_mode := FALSE;

       FOR i IN 1..p_ieu_media_data.COUNT
       LOOP

         p_ieu_media_data1.EXTEND;
         p_ieu_media_data1(p_ieu_media_data1.LAST) :=
SYSTEM.IEU_UWQ_MEDIA_DATA_OBJ(p_ieu_media_data(i).param_name,
                                                        p_ieu_media_data(i).param_value,
                                                        p_ieu_media_data(i).param_type);

                l_name  := p_ieu_media_data(i).param_name;
                l_value := p_ieu_media_data(i).param_value;
                l_type  := p_ieu_media_data(i).param_type;


                if l_name = 'UWQ_BLOCK_MODE' and l_value = 'T' then
                  l_block_mode := TRUE;
                end if;

                if l_name = 'UWQ_CONTINUOUS_MODE' and l_value = 'T' then
                  l_continuous_mode := TRUE;
                end if;

                if l_name = 'workItemID' then
                  l_action_param1 := 'p_work_item_id="'||l_value||'" ';
--                  l_action_param4 := l_action_param4||l_name||'=['||l_value||']';
                end if;

                if l_name = 'occtMediaItemID' then
                  l_action_param2 := 'p_media_item_id="'||l_value||'" ';
--                  l_action_param4 := l_action_param4||l_name||'=['||l_value||']';
                end if;

                if l_type is null or l_type <> 'IEU_UPDATE_ENABLED' then

                   if (length(l_action_param3) is null) then
                      l_action_param3:= l_action_param3||l_name||'=['||l_value||']';

                   elsif (length(l_action_param3) is not null) then

                      /* if it is not null then check total length not exceed 1850
                         total length = workitemid + occtmediaitemid + action_param3 + name + value
+ 3 (3 is adding = and squaer brackets [] to the value) */

                      if ((length(l_action_param3)+nvl(length(l_action_param1),0) +
nvl(length(l_action_param2),0)+length(l_name)+length(l_value))+3 < 1850) then
                        l_action_param3 := l_action_param3||l_name||'=['||l_value||']';
                      end if;

                   end if;
                end if;

                if l_type = 'IEU_UPDATE_ENABLED' then                /* Store all the update enabled
types to table of records */
                   p_ieu_media_data1(i).param_name := l_name;
                   p_ieu_media_data1(i).param_value := l_value;
                   p_ieu_media_data1(i).param_type := l_type;
                end if;

       END LOOP;


           /* maximum length of workitemid, occtmediaitemid and all non-update enbaled types */

           max_length := length(l_action_param1) + length(l_action_param2) +
length(l_action_param3);

          FOR i IN 1..p_ieu_media_data1.COUNT
          LOOP
                l_name  := p_ieu_media_data1(i).param_name;
                l_value := p_ieu_media_data1(i).param_value;
                l_type  := p_ieu_media_data1(i).param_type;


                  if l_type = 'IEU_UPDATE_ENABLED' then

                      if max_length < 1950 then

                        if (length(l_action_param4) is null) then
                           l_action_param4:= l_action_param4||l_name||'=['||l_value||']';

                        elsif (length(l_action_param4) is not null) then

                          if (max_length + (length(l_action_param4) +
length(l_name)+length(l_value)) +3 < 1950) then
                            l_action_param4 := l_action_param4||l_name||'=['||l_value||']';
                          end if;

                        end if;
                      end if;
                  end if; /* IEU_UPDATE_ENABLED */

          end loop;


          l_action_param3 := 'p_data="'||l_action_param3||'"';
          l_action_param4 := 'p_data1="'||l_action_param4||'"';

          p_action_type     := 1;
          if l_block_mode = TRUE or l_continuous_mode = FALSE then
            p_action_type := 2;
          end if;

          if l_block_mode = FALSE and l_continuous_mode = FALSE then
            p_action_type := 1;
          end if;

          p_action_name     := 'IEUSCPOP';
          p_action_param    := l_action_param1||l_action_param2||l_action_param3||l_action_param4;

  END;
END IEU_UWQ_FORM_ROUTE;

/
