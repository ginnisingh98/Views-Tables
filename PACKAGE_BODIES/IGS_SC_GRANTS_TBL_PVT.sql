--------------------------------------------------------
--  DDL for Package Body IGS_SC_GRANTS_TBL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SC_GRANTS_TBL_PVT" AS
/* $Header: IGSSC04B.pls 120.1 2005/06/03 08:30:48 appldev  $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Arkadi Tereshenkov

 Date Created By    : Oct-01-2002


 Purpose            : This is a package used for a grant model for each object

 remarks            :

 Change History

Who                   When           What
-----------------------------------------------------------
Arkadi Tereshenkov    Apr-10-2002    New Package created.

******************************************************************/


G_PKG_NAME         CONSTANT VARCHAR2(30) := 'IGS_SC_GRANTS_TBL_PVT';

FUNCTION  Generate_and_raise (p_object IN VARCHAR2)
RETURN VARCHAR2
IS

  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
  l_event_name    VARCHAR2(255) := 'oracle.apps.igs.sc.error';
  l_event_key     VARCHAR2(255);

BEGIN

   FND_MSg_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN

      l_msg_data := '';

      FOR l_cur IN 1..l_msg_count LOOP

         l_msg_data :=l_msg_data||'  '|| FND_MSg_PUB.GET(l_cur, FND_API.g_FALSE);

      END LOOP;

   ELSE

         l_msg_data  := 'Error Returned but Error stack has no data';
   END IF;


    RETURN l_msg_data;

    wf_event.AddParameterToList(p_name=>'OBJECT_NAME',p_value=>p_object,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ERROR_TEXT',p_value=>l_msg_data,p_parameterlist=>l_parameter_list);

    wf_event.raise( p_event_name => l_event_name,
                    p_event_key  => l_event_key,
                    p_parameters => l_parameter_list);


    l_parameter_list.DELETE;

    RETURN l_msg_data;

END Generate_and_raise;


FUNCTION get_grant
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2,
  p_action IN VARCHAR2 )
RETURN VARCHAR2 IS

  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR(2000);
  l_where_clause    VARCHAR2(32000);


BEGIN
/* Call get grant main procedure */

  -- Check if the tables are SECURITY tables:

  IF SUBSTR(p_object,1,6) = 'IGS_SC' THEN

     IF p_action = 'S' THEN

       RETURN '1=1';

     ELSE

       RETURN '1=2';

     END IF;

  END IF;

  IF SYS_CONTEXT('OSS_APP_CTX','SECURITY') IS NULL THEN
      RETURN NULL;
  ELSE
      -- If not

      IGS_SC_GRANTS_PVT.generate_grant(
        p_api_version       => 1.0,
        p_object_name       => p_object,
        p_function_type     => p_action,
        x_where_clause      => l_where_clause,
        x_return_status     =>  l_return_status,
        x_msg_count         =>  l_msg_count,
        x_msg_data          =>  l_msg_data );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        raise FND_API.G_EXC_ERROR;
      END IF;
      RETURN l_where_clause;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

    l_where_clause := Generate_and_raise(p_object);

    RETURN '1=2';

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    l_where_clause := Generate_and_raise(p_object);

    RETURN '1=2';

  WHEN OTHERS THEN

    -- Unexpected error during the execution. We need to return no wrows to the caller and raise business event

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'GET_GRANT');
     END IF;

    l_where_clause := Generate_and_raise(p_object);

    RETURN l_where_clause;

END get_grant;



FUNCTION insert_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN

  RETURN GET_GRANT ( p_schema => p_schema,
         p_object => p_object,
         p_action => 'I');

END insert_row;

FUNCTION select_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN

  RETURN GET_GRANT ( p_schema => p_schema,
         p_object => p_object,
         p_action => 'S');

END select_row;


FUNCTION update_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN

  RETURN GET_GRANT ( p_schema => p_schema,
         p_object => p_object,
         p_action => 'U');

END update_row;


FUNCTION delete_row
( p_schema IN VARCHAR2,
  p_object IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN

  RETURN GET_GRANT ( p_schema => p_schema,
         p_object => p_object,
         p_action => 'D');

END delete_row;



END IGS_SC_GRANTS_TBL_PVT;


/
