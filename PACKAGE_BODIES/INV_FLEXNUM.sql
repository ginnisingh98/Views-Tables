--------------------------------------------------------
--  DDL for Package Body INV_FLEXNUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_FLEXNUM" AS
/* $Header: INVFLEXB.pls 120.1 2005/07/01 12:20:40 appldev ship $ */

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'INV_FLEXNUM';

Function INV_GETNUM return VARCHAR2 IS
  flexff        fnd_flex_key_api.flexfield_type ;
  strcff        fnd_flex_key_api.structure_type ;
  numsegs       number ;
  seglist       fnd_flex_key_api.segment_list ;
  segtype       fnd_flex_key_api.segment_type ;
  i NUMBER;
  d VARCHAR2(100);
begin
 fnd_flex_key_api.set_session_mode('seed_data');
 flexff := fnd_flex_key_api.find_flexfield('INV','MTLL') ;
 strcff := fnd_flex_key_api.find_structure(flexff,101) ;
 fnd_flex_key_api.get_segments(flexff,strcff,TRUE,numsegs,seglist) ;
 i := 1;
 d := 'ALL';
 WHILE (i <= numsegs) LOOP
    segtype := fnd_flex_key_api.find_segment(flexff,strcff,seglist(i)) ;
    IF (segtype.column_name = 'SEGMENT19') THEN
       d := d || '\\0' || i;
    ELSIF (segtype.column_name = 'SEGMENT20') THEN
       d := d || '\\0' || i;
    END IF;
    i := i + 1;
 END LOOP;
 return(d) ;
EXCEPTION
   WHEN OTHERS THEN
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'INV_FLEXNUM'
            );
        END IF;
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INV_GETNUM;
END INV_FLEXNUM ;

/
