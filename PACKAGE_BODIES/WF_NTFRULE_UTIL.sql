--------------------------------------------------------
--  DDL for Package Body WF_NTFRULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NTFRULE_UTIL" as
 /* $Header: WFNTFRULEUTB.pls 120.1 2005/07/02 03:16:36 appldev noship $ */


--This Function returns a comma seperated list of display names for the given attributeName
--and attributeType which exists in the message types used by the given ruleName

function getAttrDisplayNameByRule(attributeName in VARCHAR2,
                                 attributeType in VARCHAR2,
				 ruleName in VARCHAR2)
return VARCHAR2
is

  displayName VARCHAR2(32000);
  cnt INTEGER := 1;

  cursor ntfrule_cursor is
   select distinct display_name from wf_message_attributes_vl where
   name = attributeName and type = attributeType and
   message_type in (select message_type from wf_ntf_rule_criteria where rule_name = ruleName);

Begin

   FOR rec IN ntfrule_cursor
   LOOP

     IF cnt = 1 THEN
       displayName := rec.display_name;

     ELSE
       displayName := displayName ||', '|| rec.display_name;

     END IF;

     cnt := cnt + 1;

   END LOOP;


   return(displayName);

  exception
   when others then
     wf_core.context('WF_NTFRULE_UTIL', 'getAttributeDisplayNameByRule', attributeName, attributeType, ruleName);
     raise;


End getAttrDisplayNameByRule;




--Used by the Find Notification Rules Conflicts page
--This Function returns a comma seperated list of display names for the given attributeName
--and attributeType which exists in the given message type.

function getAttrDisplayNameByMsgType(attributeName in VARCHAR2,
                                  attributeType in VARCHAR2,
				  messageType in VARCHAR2)
return VARCHAR2
is

  displayName VARCHAR2(32000);
  cnt INTEGER := 1;

  cursor ntfrule_cursor is
   select distinct display_name from wf_message_attributes_vl where
   name = attributeName and type = attributeType and
   message_type = messageType;

Begin

   FOR rec IN ntfrule_cursor
   LOOP

     IF cnt = 1 THEN
       displayName := rec.display_name;

     ELSE
       displayName := displayName ||', '|| rec.display_name;

     END IF;

     cnt := cnt + 1;

   END LOOP;


   return(displayName);

  exception
   when others then
     wf_core.context('WF_NTFRULE_UTIL', 'getAttributeDisplayName', attributeName, attributeType, messageType);
     raise;


End getAttrDisplayNameByMsgType;



--This function expects a comma seperated list of messagetypes
--i.e 'TSTFWKEM','WFRTFORM'...  This value is used in the IN clause of the query

--We are using REF CURSORS so as to execute a dynamic sql. We need to use dynamic sql as
--this sql requires values for its IN clause and there is no straight forward way to bind
--mutiple comma sepearated messageTypes values.

function getMsgDisplayName(attributeName in VARCHAR2,
                               attributeDisplayName in VARCHAR2,
                               attributeType in VARCHAR2,
  		 	       messageTypes in VARCHAR2)
return varchar2
is

  TYPE cur_typ IS REF CURSOR;

  ntfrule_cursor cur_typ;

  msgDisplayName VARCHAR2(720);
  displayName VARCHAR2(360);
  internalName VARCHAR2(360);

  query_stmt VARCHAR2(2000);




Begin

  query_stmt := 'select distinct display_name, name from wf_messages_vl '||
  		 'where ' ||
		 '(name,type) in '||
     		 '(select message_name, message_type from wf_message_attributes_vl '||
      		 'where '||
      		 'name = :1 and '||
      		 'display_name = :2 and '||
                 'type = :3 and '||
                 'message_type in ('||messageTypes||'))';



  OPEN ntfrule_cursor FOR query_stmt using attributeName, attributeDisplayName, attributeType;

  LOOP
      FETCH ntfrule_cursor into displayName, internalName;

      EXIT WHEN ntfrule_cursor%NOTFOUND;


      IF ntfrule_cursor%ROWCOUNT >1 THEN
      	msgDisplayName := '(Occurs in multiple messages)';
      	EXIT;

      ELSE
          msgDisplayName := displayName ||' ('||internalName||')';


      END IF;

   END LOOP;

   close ntfrule_cursor;


   return(msgDisplayName);


  exception
   when others then
     wf_core.context('WF_NTFRULE_UTIL', 'getMessageDisplayName2', attributeName, attributeType, messageTypes);
     raise;

end getMsgDisplayName;


--This function raises an event which launches the concurrent program to denormalize the
--WF_NOTIFICATIONS table. It also returns the request id of the launched concurrent program.

function raiseDenormalizeEvent(eventKey in VARCHAR2)
return varchar2
is

requestId VARCHAR2(2000);
eventName VARCHAR2(50) :='oracle.apps.fnd.wf.attribute.denormalize';
param_list wf_parameter_list_t;
sendDate DATE := SYSDATE;



Begin

  wf_event.raise3(eventName,eventKey,null,param_list,sendDate);

  requestId := wf_event.getValueForParameter('REQUEST_ID',param_list);

  return(requestId);

  exception
   when others then
     wf_core.context('WF_NTFRULE_UTIL', 'raiseDenomalizeEvent', eventKey);
     raise;

end raiseDenormalizeEvent;




/*Rosetta Wrapper Generated Code for Simulation -- Start*/


  procedure rosetta_table_copy_in_p1(t out nocopy wf_ntf_rule.custom_col_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_32767
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rule_name := a0(indx);
          t(ddindx).column_name := a1(indx);
          t(ddindx).attribute_name := a2(indx);
          t(ddindx).display_name := a3(indx);
          t(ddindx).customization_level := a4(indx);
          t(ddindx).phase := a5(indx);
          t(ddindx).override := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;

  procedure rosetta_table_copy_out_p1(t wf_ntf_rule.custom_col_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_32767
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_32767();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_32767();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rule_name;
          a1(indx) := t(ddindx).column_name;
          a2(indx) := t(ddindx).attribute_name;
          a3(indx) := t(ddindx).display_name;
          a4(indx) := t(ddindx).customization_level;
          a5(indx) := t(ddindx).phase;
          a6(indx) := t(ddindx).override;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure simulate_rules(p_message_type  VARCHAR2
    , p_message_name  VARCHAR2
    , p_customization_level  VARCHAR2
    , p3_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_32767
    , p3_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_custom_col_tbl wf_ntf_rule.custom_col_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    wf_ntf_rule.simulate_rules(p_message_type,
      p_message_name,
      p_customization_level,
      ddx_custom_col_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    WF_NTFRULE_UTIL.rosetta_table_copy_out_p1(ddx_custom_col_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      );
  end;

/*Rosetta Wrapper Generated Code for Simulation -- Finish*/

END WF_NTFRULE_UTIL;

/
