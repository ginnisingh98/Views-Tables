--------------------------------------------------------
--  DDL for Package Body XTR_OA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_OA_UTIL_PKG" as
/* $Header: xtroautb.pls 115.5 2002/11/01 23:06:34 tkkim ship $*/
function SUBMIT_REQUEST (
			  application IN varchar2,
			  program     IN varchar2,
			  description IN varchar2,
			  start_time  IN varchar2,
			  sub_request IN varchar2,
			  argument1   IN varchar2,
			  argument2   IN varchar2,
  			  argument3   IN varchar2,
			  argument4   IN varchar2,
			  argument5   IN varchar2,
			  argument6   IN varchar2,
			  argument7   IN varchar2,
			  argument8   IN varchar2,
			  argument9   IN varchar2,
			  argument10  IN varchar2,
			  argument11  IN varchar2,
			  argument12  IN varchar2,
  			  argument13  IN varchar2,
			  argument14  IN varchar2,
			  argument15  IN varchar2,
			  argument16  IN varchar2,
			  argument17  IN varchar2,
			  argument18  IN varchar2,
			  argument19  IN varchar2,
			  argument20  IN varchar2,
			  argument21  IN varchar2,
			  argument22  IN varchar2,
  			  argument23  IN varchar2,
			  argument24  IN varchar2,
			  argument25  IN varchar2,
			  argument26  IN varchar2,
			  argument27  IN varchar2,
			  argument28  IN varchar2,
			  argument29  IN varchar2,
			  argument30  IN varchar2,
			  argument31  IN varchar2,
			  argument32  IN varchar2,
  			  argument33  IN varchar2,
			  argument34  IN varchar2,
			  argument35  IN varchar2,
			  argument36  IN varchar2,
			  argument37  IN varchar2,
  			  argument38  IN varchar2,
			  argument39  IN varchar2,
			  argument40  IN varchar2,
			  argument41  IN varchar2,
  			  argument42  IN varchar2,
			  argument43  IN varchar2,
			  argument44  IN varchar2,
			  argument45  IN varchar2,
			  argument46  IN varchar2,
			  argument47  IN varchar2,
  			  argument48  IN varchar2,
			  argument49  IN varchar2,
			  argument50  IN varchar2,
			  argument51  IN varchar2,
  			  argument52  IN varchar2,
			  argument53  IN varchar2,
			  argument54  IN varchar2,
			  argument55  IN varchar2,
			  argument56  IN varchar2,
			  argument57  IN varchar2,
			  argument58  IN varchar2,
			  argument59  IN varchar2,
			  argument60  IN varchar2,
			  argument61  IN varchar2,
			  argument62  IN varchar2,
  			  argument63  IN varchar2,
			  argument64  IN varchar2,
			  argument65  IN varchar2,
			  argument66  IN varchar2,
			  argument67  IN varchar2,
			  argument68  IN varchar2,
			  argument69  IN varchar2,
			  argument70  IN varchar2,
			  argument71  IN varchar2,
			  argument72  IN varchar2,
  			  argument73  IN varchar2,
			  argument74  IN varchar2,
			  argument75  IN varchar2,
			  argument76  IN varchar2,
			  argument77  IN varchar2,
			  argument78  IN varchar2,
			  argument79  IN varchar2,
			  argument80  IN varchar2,
			  argument81  IN varchar2,
			  argument82  IN varchar2,
  			  argument83  IN varchar2,
			  argument84  IN varchar2,
			  argument85  IN varchar2,
			  argument86  IN varchar2,
			  argument87  IN varchar2,
			  argument88  IN varchar2,
			  argument89  IN varchar2,
			  argument90  IN varchar2,
			  argument91  IN varchar2,
			  argument92  IN varchar2,
  			  argument93  IN varchar2,
			  argument94  IN varchar2,
			  argument95  IN varchar2,
			  argument96  IN varchar2,
			  argument97  IN varchar2,
			  argument98  IN varchar2,
			  argument99  IN varchar2,
			  argument100  IN varchar2)
			  return number is
    req_ID        number;
    p_sub_request boolean;
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

end XTR_OA_UTIL_PKG;

/