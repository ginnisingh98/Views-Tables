--------------------------------------------------------
--  DDL for Package Body CE_P2P_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_P2P_UTIL_PKG" as
/* $Header: cep2pulb.pls 120.1 2002/11/12 21:20:44 bhchung noship $ */
function SUBMIT_REQUEST (
                          application IN varchar2 default NULL,
                          program     IN varchar2 default NULL,
                          description IN varchar2 default NULL,
                          start_time  IN varchar2 default NULL,
                          sub_request IN varchar2 default 'FALSE',
                          argument1   IN varchar2 default CHR(0),
                          argument2   IN varchar2 default CHR(0),
                          argument3   IN varchar2 default CHR(0),
                          argument4   IN varchar2 default CHR(0),
                          argument5   IN varchar2 default CHR(0),
                          argument6   IN varchar2 default CHR(0),
                          argument7   IN varchar2 default CHR(0),
                          argument8   IN varchar2 default CHR(0),
                          argument9   IN varchar2 default CHR(0),
                          argument10  IN varchar2 default CHR(0),
                          argument11  IN varchar2 default CHR(0),
                          argument12  IN varchar2 default CHR(0),
                          argument13  IN varchar2 default CHR(0),
                          argument14  IN varchar2 default CHR(0),
                          argument15  IN varchar2 default CHR(0),
                          argument16  IN varchar2 default CHR(0),
                          argument17  IN varchar2 default CHR(0),
                          argument18  IN varchar2 default CHR(0),
                          argument19  IN varchar2 default CHR(0),
                          argument20  IN varchar2 default CHR(0),
                          argument21  IN varchar2 default CHR(0),
                          argument22  IN varchar2 default CHR(0),
                          argument23  IN varchar2 default CHR(0),
                          argument24  IN varchar2 default CHR(0),
                          argument25  IN varchar2 default CHR(0),
                          argument26  IN varchar2 default CHR(0),
                          argument27  IN varchar2 default CHR(0),
                          argument28  IN varchar2 default CHR(0),
                          argument29  IN varchar2 default CHR(0),
                          argument30  IN varchar2 default CHR(0),
                          argument31  IN varchar2 default CHR(0),
                          argument32  IN varchar2 default CHR(0),
                          argument33  IN varchar2 default CHR(0),
                          argument34  IN varchar2 default CHR(0),
                          argument35  IN varchar2 default CHR(0),
                          argument36  IN varchar2 default CHR(0),
                          argument37  IN varchar2 default CHR(0),
                          argument38  IN varchar2 default CHR(0),
                          argument39  IN varchar2 default CHR(0),
                          argument40  IN varchar2 default CHR(0),
                          argument41  IN varchar2 default CHR(0),
                          argument42  IN varchar2 default CHR(0),
                          argument43  IN varchar2 default CHR(0),
                          argument44  IN varchar2 default CHR(0),
                          argument45  IN varchar2 default CHR(0),
                          argument46  IN varchar2 default CHR(0),
                          argument47  IN varchar2 default CHR(0),
                          argument48  IN varchar2 default CHR(0),
                          argument49  IN varchar2 default CHR(0),
                          argument50  IN varchar2 default CHR(0),
                          argument51  IN varchar2 default CHR(0),
                          argument52  IN varchar2 default CHR(0),
                          argument53  IN varchar2 default CHR(0),
                          argument54  IN varchar2 default CHR(0),
                          argument55  IN varchar2 default CHR(0),
                          argument56  IN varchar2 default CHR(0),
                          argument57  IN varchar2 default CHR(0),
                          argument58  IN varchar2 default CHR(0),
                          argument59  IN varchar2 default CHR(0),
                          argument60  IN varchar2 default CHR(0),
                          argument61  IN varchar2 default CHR(0),
                          argument62  IN varchar2 default CHR(0),
                          argument63  IN varchar2 default CHR(0),
                          argument64  IN varchar2 default CHR(0),
                          argument65  IN varchar2 default CHR(0),
                          argument66  IN varchar2 default CHR(0),
                          argument67  IN varchar2 default CHR(0),
                          argument68  IN varchar2 default CHR(0),
                          argument69  IN varchar2 default CHR(0),
                          argument70  IN varchar2 default CHR(0),
                          argument71  IN varchar2 default CHR(0),
                          argument72  IN varchar2 default CHR(0),
                          argument73  IN varchar2 default CHR(0),
                          argument74  IN varchar2 default CHR(0),
                          argument75  IN varchar2 default CHR(0),
                          argument76  IN varchar2 default CHR(0),
                          argument77  IN varchar2 default CHR(0),
                          argument78  IN varchar2 default CHR(0),
                          argument79  IN varchar2 default CHR(0),
                          argument80  IN varchar2 default CHR(0),
                          argument81  IN varchar2 default CHR(0),
                          argument82  IN varchar2 default CHR(0),
                          argument83  IN varchar2 default CHR(0),
                          argument84  IN varchar2 default CHR(0),
                          argument85  IN varchar2 default CHR(0),
                          argument86  IN varchar2 default CHR(0),
                          argument87  IN varchar2 default CHR(0),
                          argument88  IN varchar2 default CHR(0),
                          argument89  IN varchar2 default CHR(0),
                          argument90  IN varchar2 default CHR(0),
                          argument91  IN varchar2 default CHR(0),
                          argument92  IN varchar2 default CHR(0),
                          argument93  IN varchar2 default CHR(0),
                          argument94  IN varchar2 default CHR(0),
                          argument95  IN varchar2 default CHR(0),
                          argument96  IN varchar2 default CHR(0),
                          argument97  IN varchar2 default CHR(0),
                          argument98  IN varchar2 default CHR(0),
                          argument99  IN varchar2 default CHR(0),
                          argument100  IN varchar2 default CHR(0))
                          return number is

   req_ID              number;
   p_sub_request       boolean;

begin
        if (sub_request = 'FALSE') then
            p_sub_request := FALSE;
        else
            p_sub_request := TRUE;
        end if;
        req_ID := FND_REQUEST.SUBMIT_REQUEST(
                    application, program, description, start_time, p_sub_request,
                        Argument1,  Argument2,  Argument3,  Argument4,  Argument5,
                        Argument6,  Argument7,  Argument8,  Argument9,  Argument10,
                        Argument11, Argument12, Argument13, Argument14, Argument15,
                        Argument16, Argument17, Argument18, Argument19, Argument20,
                        Argument21, Argument22, Argument23, Argument24, Argument25,
                        Argument26, Argument27, Argument28, Argument29, Argument30,
                        Argument31, Argument32, Argument33, Argument34, Argument35,
                        Argument36, Argument37, Argument38, Argument39, Argument40,
                        Argument41, Argument42, Argument43, Argument44, Argument45,
                        Argument46, Argument47, Argument48, Argument49, Argument50,
                        Argument51, Argument52, Argument53, Argument54, Argument55,
                        Argument56, Argument57, Argument58, Argument59, Argument60,
                        Argument61, Argument62, Argument63, Argument64, Argument65,
                        Argument66, Argument67, Argument68, Argument69, Argument70,
                        Argument71, Argument72, Argument73, Argument74, Argument75,
                        Argument76, Argument77, Argument78, Argument79, Argument80,
                        Argument81, Argument82, Argument83, Argument84, Argument85,
                        Argument86, Argument87, Argument88, Argument89, Argument90,
                        Argument91, Argument92, Argument93, Argument94, Argument95,
                        Argument96, Argument97, Argument98, Argument99, Argument100);
        return(req_ID);
end;


function WAIT_FOR_REQUEST (request_id IN Number default NULL,
                           interval   IN Number default 60,
                           max_wait   IN Number default 0,
                           phase      OUT NOCOPY varchar2,
                           status     OUT NOCOPY varchar2,
                           dev_phase  OUT NOCOPY varchar2,
                           dev_status OUT NOCOPY varchar2,
                           message    OUT NOCOPY varchar2)
                           return varchar2 is

   p_result boolean;

begin
   p_result := FND_CONCURRENT.WAIT_FOR_REQUEST(
                    request_id, interval, max_wait,
                    phase, status, dev_phase,
                    dev_status, message);

   IF (p_result = FALSE) THEN
      return 'FALSE';
   ELSE
      return 'TRUE';
   END IF;

end;


procedure send_email(p_wf_role      in    VARCHAR2,
                     p_file_name          VARCHAR2,
                     p_transmission_code  VARCHAR2,
                     p_transmission_type  VARCHAR2,
                     p_process_type       VARCHAR2) as

  l_role                        VARCHAR2(100);
  l_display_role_name           VARCHAR2(100);
  l_item_key                    VARCHAR2(100);

  c_item_type  varchar2(80); -- :='CESTMTWF';
  c_process    varchar2(80); -- :='CESTMTWF_P';

begin
    l_role := null;
    l_display_role_name := null;

    --
    -- Creating a workflow process
    --

    IF p_process_type = 'STATEMENT' THEN
       select ce_p2p_inbound_stmt_s.nextval into l_item_key from dual;
       c_item_type := 'CESTMTWF';
       c_process := 'CESTMTWF_P';
    ELSIF p_process_type = 'INTRA' THEN
       select ce_p2p_inbound_intra_s.nextval into l_item_key from dual;
       c_item_type := 'CEINTRWF';
       c_process := 'CEINTRWF_P';
    ELSE
       select ce_p2p_inbound_exception_s.nextval into l_item_key from dual;
       c_item_type := 'CEEXPTWF';
       c_process := 'CEEXPTWF_P';
    END IF;

    WF_ENGINE.CreateProcess(c_item_type,l_item_key, c_process);

    --
    -- Initializing attributes
    --

    WF_ENGINE.setItemAttrText(c_item_type,l_item_key, 'WFROLE',p_wf_role);
    WF_ENGINE.setItemAttrText(c_item_type,l_item_key, 'FILENAME',p_file_name);
    WF_ENGINE.setItemAttrText(c_item_type,l_item_key, 'TRANCODE',p_transmission_code);
    WF_ENGINE.setItemAttrText(c_item_type,l_item_key, 'TRANSMISSION_TYPE',p_transmission_type);
    --WF_ENGINE.setItemAttrText(c_item_type,l_item_key, 'ADHOCROLE',l_role);

    --
    -- Starting the process
    --

    WF_ENGINE.startProcess(c_item_type, l_item_key);
    commit;
end;



END CE_P2P_UTIL_PKG;

/
