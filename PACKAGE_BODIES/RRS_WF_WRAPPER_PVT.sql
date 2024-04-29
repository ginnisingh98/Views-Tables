--------------------------------------------------------
--  DDL for Package Body RRS_WF_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_WF_WRAPPER_PVT" as
/* $Header: RRSBUSEB.pls 120.0.12010000.2 2010/01/22 23:54:59 pochang noship $ */
PROCEDURE Raise_RRS_Event(p_event_type VARCHAR2,
                          p_siteId     VARCHAR2,
                          p_site_identification_number  VARCHAR2,
                          p_sg_type VARCHAR2,
                          p_sg_name VARCHAR2,
						  p_event_subtype VARCHAR2,
                          x_msg_data  OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)
IS
  l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_parameter_t            WF_PARAMETER_T      := WF_PARAMETER_T(null, null);
    l_event_name             VARCHAR2(240);
    l_event_key              VARCHAR2(240);
    l_event_num              NUMBER;
    l_event_data  clob;
    l_send_date date;
BEGIN
   l_send_date := sysdate;
   IF p_event_type = 'UpdateSite' THEN
      l_event_name := 'oracle.apps.rrs.site.updateSiteEvent';
   ELSIF p_event_type = 'CreateSite' THEN
      l_event_name := 'oracle.apps.rrs.site.createSiteEvent';
   ELSIF p_event_type = 'Bulkload' THEN
      l_event_name := 'oracle.apps.rrs.site.postSiteBulkLoadEvent';
   ELSIF p_event_type = 'CreateCluster' THEN
      l_event_name := 'oracle.apps.rrs.site.createClusterEvent';
   ELSIF p_event_type = 'UpdateCluster' THEN
      l_event_name := 'oracle.apps.rrs.site.updateClusterEvent';
   ELSIF p_event_type = 'CreateHierarchy' THEN
      l_event_name := 'oracle.apps.rrs.site.createHierarchyEvent';
   ELSIF p_event_type = 'UpdateHierarchy' THEN
      l_event_name := 'oracle.apps.rrs.site.updateHierarchyEvent';
   END IF;

   SELECT MTL_BUSINESS_EVENTS_S.NEXTVAL into l_event_num FROM dual;
   l_event_key := SUBSTRB(l_event_name, 1, 255) || '-' || l_event_num;

   --DBMS_OUTPUT.PUT_LINE('l_event_key : '||l_event_key );
   wf_event.AddParameterToList( p_name => 'SITEID'
                               ,p_value  => p_siteId
                               ,p_ParameterList => l_parameter_List);
   wf_event.AddParameterToList( p_name => 'SITE_IDENTIFICATION_NUMBER'
                               ,p_value  => p_site_identification_number
                               ,p_ParameterList => l_parameter_List);
   wf_event.AddParameterToList( p_name => 'SGTYPE'
                               ,p_value  => p_sg_type
                               ,p_ParameterList => l_parameter_List);
   wf_event.AddParameterToList( p_name => 'SGNAME'
                               ,p_value  => p_sg_name
                               ,p_ParameterList => l_parameter_List);
   wf_event.AddParameterToList( p_name => 'EVENTSUBTYPE'
                               ,p_value  => p_event_subtype
							   ,p_ParameterList => l_parameter_List);

    WF_EVENT.Raise( p_event_name => l_event_name
                       ,p_event_key  => l_event_key
                       ,p_event_data => l_event_data
                       ,p_parameters => l_parameter_list
                       ,p_send_date => l_send_date);

   l_parameter_list.DELETE;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
     WHEN Others THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data := SQLERRM;

END Raise_RRS_Event;
END RRS_WF_WRAPPER_PVT;

/
