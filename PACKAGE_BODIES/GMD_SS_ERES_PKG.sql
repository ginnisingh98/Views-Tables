--------------------------------------------------------
--  DDL for Package Body GMD_SS_ERES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SS_ERES_PKG" AS
/* $Header: GMDQSERB.pls 115.1 2003/04/30 14:09:40 hsaleeb noship $ */

/* ######################################################################## */

PROCEDURE GET_TO_STATUS(
   /* procedure to get target status desc */
      p_instatus      IN NUMBER,
      p_outstatus_desc     OUT NOCOPY VARCHAR2
   ) is

   target_status number;
   target_status_desc VARCHAR2(240);

cursor c is
	select meaning
 	from gmd_qc_status_tl
	where status_code = target_status
	and entity_type = 'STABILITY'
	and language = USERENV('LANG') ;

begin

    if (p_instatus = 400) then
	/* requesting Approval */
	target_status := 200;
   elsif (p_instatus = 700) then
	/* requesting Launch */
	target_status := 500;
   elsif (p_instatus = 1000) then
	/* requesting Cancel */
	target_status := 900;
   end if;


   open c;
	fetch c into target_status_desc;
   close c;

   p_outstatus_desc := target_status_desc ;

end GET_TO_STATUS;


PROCEDURE GET_RESOURCE_DESC(
   /* procedure to get Resource Description */
      p_se_id      IN NUMBER,
      p_resource_desc     OUT NOCOPY VARCHAR2
   ) IS

 Cursor C1 is
 SELECT cr.resource_desc
      from cr_rsrc_mst cr,
         gmp_resource_instances ri,
        cr_rsrc_dtl rd,
        gmd_sampling_events samples
 WHERE samples.sampling_event_id = p_se_id
         and ri.inactive_ind = 0
         and rd.resource_id = ri.resource_id
         and rd.orgn_code = Samples.orgn_code
         and cr.resources = samples.resources
         and rd.resources = samples.resources
         and ri.instance_id = samples.instance_id
         and cr.delete_mark = 0 ;


begin

	open c1;
		fetch c1 into p_resource_desc ;
	close c1;

end GET_RESOURCE_DESC ;




END GMD_SS_ERES_PKG ;

/
