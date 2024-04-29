--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_WORK_PANEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_WORK_PANEL_PVT" AS
/* $Header: IEUVUWPB.pls 120.0 2005/06/02 15:50:41 appldev noship $ */

PROCEDURE GET_UWQ_ACTION_DATA
(P_UWQ_ACTION_DATA        IN    VARCHAR2,
 X_UWQ_ACTION_DATA_LIST  OUT NOCOPY    IEU_UWQ_WORK_PANEL_PUB.UWQ_ACTION_DATA_REC_LIST) AS

 tempString   varchar2(4000);
 list_ctr     number := 0;
 j            number;
 k            number;
 l_counter    number;

BEGIN

 j:= 1;
 l_counter := 1;
 k := 1;

 IF (length(p_uwq_action_data) is not null)
 THEN
   WHILE (l_counter < length(p_uwq_action_data) )
   LOOP
       tempString :=  substr
                     (
                        p_uwq_action_data,
                        instr(p_uwq_action_data, fnd_global.local_chr(20),1,j),
                        ( instr(p_uwq_action_data, fnd_global.local_chr(28),1,j) -
                          instr(p_uwq_action_data, fnd_global.local_chr(20),1,j) + 1)
                     );

        x_uwq_action_data_list(list_ctr).name :=
            substr
              ( tempString,
                2,
                instr(tempString, fnd_global.local_chr(31),1,k) - 2
              );
        x_uwq_action_data_list(list_ctr).value :=
          substr
              ( tempString,
                instr(tempString, fnd_global.local_chr(31),1,k) + 1,
                ( instr(tempString,fnd_global.local_chr(31),1,k+1) -
                  instr(tempString, fnd_global.local_chr(31),1,k) - 1)
              );
        x_uwq_action_data_list(list_ctr).type :=
          substr
              ( tempString,
                instr(tempString, fnd_global.local_chr(31),1,k+1) + 1,
                length(tempstring) - instr(tempString, fnd_global.local_chr(31),1,k+1) -1
              );

        l_counter := instr(p_uwq_action_data, fnd_global.local_chr(28),1,j);
        j := j+1;
        list_ctr := list_ctr + 1;

    END LOOP;
  END IF;

END GET_UWQ_ACTION_DATA;
PROCEDURE CALL_WORK_ACTIONS
 (p_resource_id         IN  NUMBER,
  p_langauge            IN  VARCHAR2,
  p_source_lang         IN  VARCHAR2,
  p_action_key          IN  VARCHAR2,
  p_action_proc         IN VARCHAR2,
  p_work_action_data	IN IEU_UWQ_WORK_PANEL_PUB.uwq_action_data_rec_list,
  x_uwq_action_list    OUT NOCOPY IEU_UWQ_WORK_PANEL_PUB.uwq_action_rec_list,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2) IS

 l_work_action_data system.ACTION_INPUT_DATA_NST;
 x_uwq_action_data SYSTEM.IEU_UWQ_WORK_ACTIONS_NST;
 l_token_str       VARCHAR2(500);

BEGIN


 l_work_action_data := system.ACTION_INPUT_DATA_NST();
 x_uwq_action_data :=  SYSTEM.IEU_UWQ_WORK_ACTIONS_NST();

 FND_MSG_PUB.INITIALIZE;

 FOR i in p_work_action_data.first .. p_work_action_data.last
 LOOP
   l_work_action_data.extend;
   l_work_action_data(l_work_action_data.last) := system.ACTION_INPUT_DATA_OBJ
                                                 (
                                                  p_work_action_data(i).dataSetType,
                                                  p_work_action_data(i).dataSetID,
                                                  p_work_action_data(i).name,
                                                  p_work_action_data(i).value,
                                                  p_work_action_data(i).type);
 END LOOP;

 BEGIN
  EXECUTE IMMEDIATE 'BEGIN '||p_action_proc||'( :1, :2, :3, :4 , :5, :6, :7, :8, :9);  END;'
   USING IN p_resource_id, IN p_langauge, IN p_source_lang, IN p_action_key, IN l_work_action_data ,
       OUT x_uwq_action_data, OUT x_msg_count, OUT x_msg_data, OUT x_return_status;
 EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    l_token_str := substr(sqlerrm,1,150);
    FND_MESSAGE.SET_NAME('IEU', 'IEU_WP_EXEC_WORK_ACT_FAILED');
    FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','GET_UWQ_ACTION_DATA.CALL_WORK_ACTIONS');
    FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

    fnd_msg_pub.ADD;
    fnd_msg_pub.Count_and_Get
    (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
    );
--     x_msg_data := sqlerrm;
  END;

  if (x_return_status = 'S')
  then
   if x_uwq_action_data is not null then
    FOR i in 1..x_uwq_action_data.count
    LOOP
       x_uwq_action_list(i).uwq_action_key := x_uwq_action_data(i).uwq_action_key;
       x_uwq_action_list(i).action_data    := x_uwq_action_data(i).action_data;
       x_uwq_action_list(i).dialog_style   := x_uwq_action_data(i).dialog_style;
       x_uwq_action_list(i).message        := x_uwq_action_data(i).message;
    END LOOP;
   end if;
  else
    l_token_str := substr(sqlerrm,1,150);
    FND_MESSAGE.SET_NAME('IEU', 'IEU_WP_EXEC_WORK_ACT_FAILED');
    FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','GET_UWQ_ACTION_DATA.CALL_WORK_ACTIONS');
    FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

    fnd_msg_pub.ADD;
    fnd_msg_pub.Count_and_Get
    (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
    );
  end if;

END CALL_WORK_ACTIONS;
/*
PROCEDURE CALL_INFO_ACTIONS (
 p_resource_id           IN  NUMBER,
 p_language              IN  VARCHAR2,
 p_source_lang           IN  VARCHAR2,
 p_action_key            IN  VARCHAR2,
 p_exec_proc             IN  VARCHAR2,
 p_workitem_data_list    IN  IEU_UWQ_WORK_PANEL_PUB.uwq_action_data_rec_list,
 x_work_notes_long_list  OUT NOCOPY  IEU_UWQ_WORK_PANEL_PVT.t_work_notes_long_data,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2,
 x_return_status         OUT NOCOPY VARCHAR2
 )
is

l_workitem_data_list    SYSTEM.ACTION_INPUT_DATA_NST;
l_work_notes_data_list  SYSTEM.app_info_data_nst;
l_work_notes_clob_list   IEU_UWQ_WORK_PANEL_PUB.t_app_info_data_rec_list;
l_token_str             VARCHAR2(500);

  clob_selected             CLOB;
  read_amount               NUMBER;
  read_offset               NUMBER;
  buffer                    long;
  clob_length               number;
  l_ctr                     binary_integer;
BEGIN

---- Convert  p_workitem_data_list(TOR) to l_workitem_data_list(NESTED)--
 l_workitem_data_list  :=  SYSTEM.ACTION_INPUT_DATA_NST();

 FND_MSG_PUB.INITIALIZE;

 for i in 1..p_workitem_data_list.count loop
     l_workitem_data_list.EXTEND;
     l_workitem_data_list(l_workitem_data_list.LAST) := SYSTEM.ACTION_INPUT_DATA_OBJ(
                          null,
                          null,
                          p_workitem_data_list(i).NAME,
                          p_workitem_data_list(i).VALUE,
                          p_workitem_data_list(i).TYPE
                          );
 end loop;

-------- remove after testing nto sure ---------------
l_work_notes_data_list  := SYSTEM.app_info_data_nst();
------------------------------------------------------
BEGIN

   execute immediate
   'begin '|| p_exec_proc || '(' || ':p_resource_id,' || ':p_language,' || ':p_source_lang,' || ':p_action_key,' || ':l_workitem_data_list,' || ':l_work_notes_data_list,' || ':x_msg_count,' ||':x_msg_data,' || ':x_return_status);end;'
   using in p_resource_id, p_language, p_source_lang, p_action_key, l_workitem_data_list, out l_work_notes_data_list, out x_msg_count, out x_msg_data, out x_return_status;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := 'E';
    l_token_str := substr(sqlerrm,1,150);
    FND_MESSAGE.SET_NAME('IEU', 'IEU_WP_EXEC_INFO_ACT_FAILED');
    FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','GET_UWQ_ACTION_DATA.CALL_INFO_ACTIONS');
    FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

    fnd_msg_pub.ADD;
    fnd_msg_pub.Count_and_Get
    (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
    );
--     x_msg_data := sqlerrm;
  END;

---- Convert  l_work_notes_data_list(NESTED CLOB) to l_workitem_data_list(TOR LONG)--
begin
     read_offset := 1;
     l_ctr       := 1;
for i in 1..l_work_notes_data_list.count loop
       clob_selected := l_work_notes_data_list(i).APP_INFO_DETAIL;
       clob_length   := dbms_lob.getlength(clob_selected);
--dbms_output.put_line('Clob length : ' || to_char(clob_length));
       if  read_offset > clob_length then
           x_work_notes_long_list(l_ctr).REC_ID     := i;
           x_work_notes_long_list(l_ctr).NOTES_HEAD := l_work_notes_data_list(i).APP_INFO_HEADER;
           x_work_notes_long_list(l_ctr).NOTES_DET  := buffer;
           l_ctr := l_ctr + 1;
       end if;
       while read_offset <= clob_length loop
       read_amount := 32700;
       dbms_lob.read(clob_selected, read_amount, read_offset, buffer);
       x_work_notes_long_list(l_ctr).REC_ID     := i;
       x_work_notes_long_list(l_ctr).NOTES_HEAD := l_work_notes_data_list(i).APP_INFO_HEADER;
       x_work_notes_long_list(l_ctr).NOTES_DET  := buffer;
       l_ctr := l_ctr + 1;
--dbms_output.put_line('Total: ' || dbms_lob.getlength(clob_selected)  || ' Selected: ' || length(buffer));
--dbms_output.put_line('Buffer length : ' || length(buffer));
       buffer := null;
       read_offset := read_offset + read_amount;
     end loop;
end loop;
exception
  when no_data_found then null;
end;

END CALL_INFO_ACTIONS;
*/
PROCEDURE CALL_INFO_ACTIONS (
 p_resource_id           IN  NUMBER,
 p_language              IN  VARCHAR2,
 p_source_lang           IN  VARCHAR2,
 p_action_key            IN  VARCHAR2,
 p_exec_proc             IN  VARCHAR2,
 p_workitem_data_list    IN  IEU_UWQ_WORK_PANEL_PUB.uwq_action_data_rec_list,
 x_work_notes_long_list  OUT NOCOPY IEU_UWQ_WORK_PANEL_PVT.t_work_notes_long_data,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2,
 x_return_status         OUT NOCOPY VARCHAR2
 )
is

l_workitem_data_list    SYSTEM.ACTION_INPUT_DATA_NST;
l_work_notes_data_list  SYSTEM.APP_INFO_HEADER_NST;
--l_work_notes_clob_list   IEU_UWQ_WORK_PANEL_PUB.t_app_info_data_rec_list;
l_token_str             VARCHAR2(500);
l_prev_header           varchar2(4000);
l_curr_header           varchar2(4000);
l_first_header          varchar2(1);
l_rec_id                number(10);

  clob_selected             CLOB;
  read_amount               NUMBER;
  read_offset               NUMBER;
--  buffer                    VARCHAR2(32767);
  buffer                    long;
  clob_length               number;
  l_ctr                     binary_integer;
BEGIN

l_first_header := 'Y';
---- Convert  p_workitem_data_list(TOR) to l_workitem_data_list(NESTED)--
 l_workitem_data_list  :=  SYSTEM.ACTION_INPUT_DATA_NST();
 l_work_notes_data_list  :=  SYSTEM.APP_INFO_HEADER_NST();

 FND_MSG_PUB.INITIALIZE;

 for i in 1..p_workitem_data_list.count loop
     l_workitem_data_list.EXTEND;
     l_workitem_data_list(l_workitem_data_list.LAST) := SYSTEM.ACTION_INPUT_DATA_OBJ(
                          null,
                          null,
                          p_workitem_data_list(i).NAME,
                          p_workitem_data_list(i).VALUE,
                          p_workitem_data_list(i).TYPE
                          );
 end loop;

BEGIN
   execute immediate
   'begin '|| p_exec_proc || '(' || ':p_resource_id,' || ':p_language,' || ':p_source_lang,' || ':p_action_key,' || ':l_workitem_data_list,' || ':l_work_notes_data_list,' || ':x_msg_count,' ||':x_msg_data,' || ':x_return_status);end;'
   using in p_resource_id, p_language, p_source_lang, p_action_key, l_workitem_data_list, out l_work_notes_data_list, out x_msg_count, out x_msg_data, out x_return_status;


    for i in 1..l_work_notes_data_list.count loop
        x_work_notes_long_list(i).REC_ID     := i;
        x_work_notes_long_list(i).NOTES_HEAD := l_work_notes_data_list(i).APP_INFO_HEADER;
        x_work_notes_long_list(i).NOTES_DET  := null;
--  dbms_output.put_line('Sample Count ' || x_work_notes_long_list.count );
    end loop;

EXCEPTION
   WHEN OTHERS THEN
    x_return_status := 'E';
    l_token_str := substr(sqlerrm,1,150);
    FND_MESSAGE.SET_NAME('IEU', 'IEU_WP_EXEC_INFO_ACT_FAILED');
    FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','GET_UWQ_ACTION_DATA.CALL_INFO_ACTIONS');
    FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

    fnd_msg_pub.ADD;
    fnd_msg_pub.Count_and_Get
    (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
    );

--     x_msg_data := sqlerrm;
  END;

END CALL_INFO_ACTIONS;


PROCEDURE CALL_MESG_ACTIONS (
 p_resource_id           IN  NUMBER,
 p_language              IN  VARCHAR2,
 p_source_lang           IN  VARCHAR2,
 p_action_key            IN  VARCHAR2,
 p_exec_proc             IN  VARCHAR2,
 p_workitem_data_list    IN  IEU_UWQ_WORK_PANEL_PUB.uwq_action_data_rec_list,
 x_work_mesg             OUT NOCOPY VARCHAR2,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2,
 x_return_status         OUT NOCOPY VARCHAR2
 )
is

l_workitem_data_list    SYSTEM.ACTION_INPUT_DATA_NST;
l_uwq_mesg              VARCHAR2(2000);
l_token_str             VARCHAR2(500);

BEGIN

---- Convert  p_workitem_data_list(TOR) to l_workitem_data_list(NESTED)--
 l_workitem_data_list  :=  SYSTEM.ACTION_INPUT_DATA_NST();

 FND_MSG_PUB.INITIALIZE;

 for i in 1..p_workitem_data_list.count loop
     l_workitem_data_list.EXTEND;
     l_workitem_data_list(l_workitem_data_list.LAST) := SYSTEM.ACTION_INPUT_DATA_OBJ(
                          null,
                          null,
                          p_workitem_data_list(i).NAME,
                          p_workitem_data_list(i).VALUE,
                          p_workitem_data_list(i).TYPE
                          );
 end loop;

 BEGIN
     execute immediate
     'begin '|| p_exec_proc || '(' || ':p_resource_id,' || ':p_language,' || ':p_source_lang,' || ':p_action_key,' || ':l_workitem_data_list,' || ':l_uwq_mesg,' || ':x_msg_count,' ||':x_msg_data,' || ':x_return_status);end;'
     using in p_resource_id, p_language, p_source_lang, p_action_key, l_workitem_data_list, out x_work_mesg, out x_msg_count, out x_msg_data, out x_return_status;
 EXCEPTION
   WHEN OTHERS THEN
    x_return_status := 'E';
    l_token_str := substr(sqlerrm,1,150);
    FND_MESSAGE.SET_NAME('IEU', 'IEU_WP_EXEC_MESG_ACT_FAILED');
    FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','GET_UWQ_ACTION_DATA.CALL_MESG_ACTIONS');
    FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

    fnd_msg_pub.ADD;
    fnd_msg_pub.Count_and_Get
    (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
    );
--     x_msg_data := sqlerrm;
  END;

END CALL_MESG_ACTIONS;

END IEU_UWQ_WORK_PANEL_PVT;

/
