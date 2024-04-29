--------------------------------------------------------
--  DDL for Package JTF_ACTIVITY_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ACTIVITY_MANAGER" AUTHID CURRENT_USER AS
/* $Header: jtfactls.pls 120.1 2005/07/02 02:30:13 appldev ship $ */

Type t_valuetable IS TABLE of varchar2(255)
index by binary_integer;

TYPE v_valuearray IS VARRAY (41) OF varchar2(255);

procedure write( appid IN number, activityname IN varchar2,
	 	 attrnames IN t_valuetable, valuen IN t_valuetable );

procedure write (appid IN number, activityname IN varchar2, attrnames IN v_valuearray, valuen IN v_valuearray);

procedure write(
 app_id IN number,
 activity_name IN varchar2,
 userid number,
 component varchar2,
 num_attributes number,
 attribute1 varchar2 default null,
 value1 varchar2 default null,
 attribute2 varchar2 default null,
 value2 varchar2 default null,
 attribute3 varchar2 default null,
 value3 varchar2 default null,
 attribute4 varchar2 default null,
 value4 varchar2 default null,
 attribute5 varchar2 default null,
 value5 varchar2 default null,
 attribute6 varchar2 default null,
 value6 varchar2 default null,
 attribute7 varchar2 default null,
 value7 varchar2 default null,
 attribute8 varchar2 default null,
 value8 varchar2 default null,
 attribute9 varchar2 default null,
 value9 varchar2 default null,
 attribute10 varchar2 default null,
 value10 varchar2 default null,
 attribute11 varchar2 default null,
 value11 varchar2 default null,
 attribute12 varchar2 default null,
 value12 varchar2 default null,
 attribute13 varchar2 default null,
 value13 varchar2 default null,
 attribute14 varchar2 default null,
 value14 varchar2 default null,
 attribute15 varchar2 default null,
 value15 varchar2 default null,
 attribute16 varchar2 default null,
 value16 varchar2 default null,
 attribute17 varchar2 default null,
 value17 varchar2 default null,
 attribute18 varchar2 default null,
 value18 varchar2 default null,
 attribute19 varchar2 default null,
 value19 varchar2 default null,
 attribute20 varchar2 default null,
 value20 varchar2 default null,
 attribute21 varchar2 default null,
 value21 varchar2 default null,
 attribute22 varchar2 default null,
 value22 varchar2 default null,
 attribute23 varchar2 default null,
 value23 varchar2 default null,
 attribute24 varchar2 default null,
 value24 varchar2 default null,
 attribute25 varchar2 default null,
 value25 varchar2 default null,
 attribute26 varchar2 default null,
 value26 varchar2 default null,
 attribute27 varchar2 default null,
 value27 varchar2 default null,
 attribute28 varchar2 default null,
 value28 varchar2 default null,
 attribute29 varchar2 default null,
 value29 varchar2 default null,
 attribute30 varchar2 default null,
 value30 varchar2 default null,
 attribute31 varchar2 default null,
 value31 varchar2 default null,
 attribute32 varchar2 default null,
 value32 varchar2 default null,
 attribute33 varchar2 default null,
 value33 varchar2 default null,
 attribute34 varchar2 default null,
 value34 varchar2 default null,
 attribute35 varchar2 default null,
 value35 varchar2 default null,
 attribute36 varchar2 default null,
 value36 varchar2 default null,
 attribute37 varchar2 default null,
 value37 varchar2 default null,
 attribute38 varchar2 default null,
 value38 varchar2 default null,
 attribute39 varchar2 default null,
 value39 varchar2 default null,
 attribute40 varchar2 default null,
 value40 varchar2 default null);

procedure run;
end jtf_activity_manager;

 

/
