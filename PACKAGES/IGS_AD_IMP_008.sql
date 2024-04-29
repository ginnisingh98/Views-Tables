--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_008" AUTHID CURRENT_USER AS
/* $Header: IGSAD86S.pls 120.0 2005/06/01 21:25:59 appldev noship $ */
/* Change History
   Who        when          What
   -- Bug : 2103692
   -- ssawhney : Person Interface DLD. Added in prc_pe_stat_main and
   -- prc_pe_stat_biodemo
*/

PROCEDURE Prc_Pe_Relns (
   p_batch_id IN NUMBER,
   p_source_type_id IN NUMBER );


PROCEDURE Prc_Pe_Stat(
   p_source_type_id IN	NUMBER,
   p_batch_id IN NUMBER );

-- added 2 by ssawhney

PROCEDURE Prc_Pe_Stat_Biodemo (
   p_source_type_id IN  NUMBER,
   p_batch_id IN NUMBER );

PROCEDURE Prc_Pe_Stat_Main(
   p_source_type_id IN	NUMBER,
   p_batch_id IN NUMBER );


PROCEDURE Crt_Rel_Acad_His (
   p_interface_relations_id NUMBER,
   p_rel_person_id NUMBER,
   p_source_type_id NUMBER);


PROCEDURE Crt_Rel_Adr (
   p_interface_relations_id NUMBER,
   p_rel_person_id NUMBER,
   p_source_type_id NUMBER);

PROCEDURE Prc_Rel_Con_Dtl (
   p_interface_relations_id NUMBER,
   p_rel_person_id NUMBER,
   p_source_type_id NUMBER);

PROCEDURE Crt_Relns_Emp_Dtls(
   p_relemp_rec	igs_ad_relemp_int_all%ROWTYPE,
   p_person_id NUMBER);

PROCEDURE Prc_Relns_Emp_Dtls(
   p_interface_relations_id NUMBER,
   p_rel_person_id NUMBER ,
   p_source_type_id NUMBER) ;

PROCEDURE Prc_Pe_Spl_Needs (
   p_source_type_id	IN	NUMBER,
   p_batch_id	IN	NUMBER );




END Igs_Ad_Imp_008;

 

/
