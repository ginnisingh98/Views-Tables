--------------------------------------------------------
--  DDL for Package Body GMD_EDR_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_EDR_STANDARD" AS
/* $Header: GMDERDSB.pls 120.1 2006/02/10 14:01:55 txdaniel noship $ */

--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
  --Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST, END

/*======================================================================
--  PROCEDURE :
--   raise_event
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for invoking the workflow
--     raise event.
--  REQUIREMENTS
--
--  SYNOPSIS:
--    raise_event ('oracle.apps.gmd.operation.sts', 100,'DEFERED', 'Y');
--
--===================================================================== */
PROCEDURE raise_event (p_event_name      in varchar2,
                       p_event_key        in varchar2,
                       p_parameter_name1  in varchar2,
                       p_parameter_value1 in varchar2,
                       p_parameter_name2  in varchar2 ,
                       p_parameter_value2 in varchar2 ,
                       p_parameter_name3  in varchar2 ,
                       p_parameter_value3 in varchar2 ,
                       p_parameter_name4  in varchar2 ,
                       p_parameter_value4 in varchar2 ,
                       p_parameter_name5  in varchar2 ,
                       p_parameter_value5 in varchar2 ,
                       p_parameter_name6  in varchar2 ,
                       p_parameter_value6 in varchar2 ,
                       p_parameter_name7  in varchar2 ,
                       p_parameter_value7 in varchar2 ,
                       p_parameter_name8  in varchar2 ,
                       p_parameter_value8 in varchar2 ,
                       p_parameter_name9  in varchar2 ,
                       p_parameter_value9 in varchar2 ,
                       p_parameter_name10  in varchar2,
                       p_parameter_value10 in varchar2) IS

  p_erecord_ids      edr_eres_event_pub.erecord_id_tbl_type;
  x_event_rec        edr_eres_event_pub.eres_event_rec_type;

  x_msg_count        NUMBER;
  x_msg_data         VARCHAR2(2000);
  l_return_status    VARCHAR2(1);

BEGIN

  -- p_erecord_ids(1) := NULL;

  x_event_rec.event_name := p_event_name;
  x_event_rec.event_key  := p_event_key;

  IF (p_parameter_name1 is not NULL) THEN
     x_event_rec.param_name_1  := p_parameter_name1;
     x_event_rec.param_value_1 := p_parameter_value1;
  END IF;

  IF (p_parameter_name2 is not NULL) THEN
     x_event_rec.param_name_2  := p_parameter_name2;
     x_event_rec.param_value_2 := p_parameter_value2;
  END IF;

  IF (p_parameter_name3 is not NULL) THEN
     x_event_rec.param_name_3  := p_parameter_name3;
     x_event_rec.param_value_3 := p_parameter_value3;
  END IF;

  IF (p_parameter_name4 is not NULL) THEN
     x_event_rec.param_name_4  := p_parameter_name4;
     x_event_rec.param_value_4 := p_parameter_value4;
  END IF;

  IF (p_parameter_name5 is not NULL) THEN
     x_event_rec.param_name_5  := p_parameter_name5;
     x_event_rec.param_value_5 := p_parameter_value5;
  END IF;

  IF (p_parameter_name6 is not NULL) THEN
     x_event_rec.param_name_6  := p_parameter_name6;
     x_event_rec.param_value_6 := p_parameter_value6;
  END IF;

  IF (p_parameter_name7 is not NULL) THEN
     x_event_rec.param_name_7  := p_parameter_name7;
     x_event_rec.param_value_7 := p_parameter_value7;
  END IF;

  IF (p_parameter_name8 is not NULL) THEN
     x_event_rec.param_name_8  := p_parameter_name8;
     x_event_rec.param_value_8 := p_parameter_value8;
  END IF;

  IF (p_parameter_name9 is not NULL) THEN
     x_event_rec.param_name_9  := p_parameter_name9;
     x_event_rec.param_value_9 := p_parameter_value9;
  END IF;

  IF (p_parameter_name10 is not NULL) THEN
     x_event_rec.param_name_10  := p_parameter_name10;
     x_event_rec.param_value_10 := p_parameter_value10;
  END IF;

  EDR_ERES_EVENT_PUB.raise_eres_event
  ( p_api_version       =>   1.0
  , p_init_msg_list	=>   FND_API.G_TRUE
  , p_validation_level	=>   FND_API.G_VALID_LEVEL_FULL
  , x_return_status	=>   l_return_status
  , x_msg_count		=>   x_msg_count
  , x_msg_data		=>   x_msg_data
  , p_child_erecords 	=>   p_erecord_ids --NULL
  , x_event             =>   x_event_rec);

  IF x_event_rec.erecord_id IS NOT NULL THEN
    EDR_TRANS_ACKN_PUB.SEND_ACKN
    ( p_api_version     =>   1.0
    , p_init_msg_list	=>   FND_API.G_TRUE
    , x_return_status	=>   l_return_status
    , x_msg_count	=>   x_msg_count
    , x_msg_data	=>   x_msg_data
    , p_event_name      =>   p_event_name
    , p_event_key       =>   p_event_key
    , p_erecord_id	=>   x_event_rec.erecord_id
    , p_trans_status	=>   'SUCCESS'
    , p_ackn_by         =>   NULL
    , p_ackn_note	  =>   NULL
    , p_autonomous_commit =>   FND_API.G_FALSE
    );
  END IF;

END raise_event;

END GMD_EDR_STANDARD;

/
