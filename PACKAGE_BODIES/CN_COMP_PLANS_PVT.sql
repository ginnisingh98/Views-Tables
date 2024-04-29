--------------------------------------------------------
--  DDL for Package Body CN_COMP_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_PLANS_PVT" as
/* $Header: cnxvcmpb.pls 115.1 2001/10/29 17:32:01 pkm ship    $ */

PROCEDURE create_comp_plan_client
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT   VARCHAR2,
   x_msg_count	        OUT   NUMBER,
   x_msg_data	        OUT   VARCHAR2,
   p_comp_plan_name     IN    VARCHAR2,
   p_description        IN    VARCHAR2,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_status             IN    VARCHAR2,
   p_rc_overlap         IN    VARCHAR2,
   p_attribute1         IN    VARCHAR2,
   p_attribute2         IN    VARCHAR2,
   p_attribute3         IN    VARCHAR2,
   p_attribute4         IN    VARCHAR2,
   p_attribute5         IN    VARCHAR2,
   p_attribute6         IN    VARCHAR2,
   p_attribute7         IN    VARCHAR2,
   p_attribute8         IN    VARCHAR2,
   p_attribute9         IN    VARCHAR2,
   p_attribute10        IN    VARCHAR2,
   p_attribute11        IN    VARCHAR2,
   p_attribute12        IN    VARCHAR2,
   p_attribute13        IN    VARCHAR2,
   p_attribute14        IN    VARCHAR2,
   p_attribute15        IN    VARCHAR2,
   p_plan_element_name  IN    VARCHAR2,
   x_comp_plan_id       OUT   NUMBER,
   x_loading_status     OUT   VARCHAR2
   ) IS

      l_comp_rec       cn_comp_plan_pub.comp_plan_rec_type;
BEGIN

   l_comp_rec.name              := p_comp_plan_name;
   l_comp_rec.description       := p_description;
   l_comp_rec.start_date        := p_Start_date;
   l_comp_rec.end_date          := p_end_date;
   l_comp_rec.status            := p_status;
   l_comp_rec.rc_overlap        := p_rc_overlap;
   l_comp_rec.plan_element_name := p_plan_element_name;
   l_comp_rec.attribute1        := p_attribute1;
   l_comp_rec.attribute2        := p_attribute2;
   l_comp_rec.attribute3        := p_attribute3;
   l_comp_rec.attribute4        := p_attribute4;
   l_comp_rec.attribute5        := p_attribute5;
   l_comp_rec.attribute6        := p_attribute6;
   l_comp_rec.attribute7        := p_attribute7;
   l_comp_rec.attribute8        := p_attribute8;
   l_comp_rec.attribute9        := p_attribute9;
   l_comp_rec.attribute10        := p_attribute10;
   l_comp_rec.attribute11        := p_attribute11;
   l_comp_rec.attribute12        := p_attribute12;
   l_comp_rec.attribute13        := p_attribute13;
   l_comp_rec.attribute14        := p_attribute14;
   l_comp_rec.attribute15        := p_attribute15;


     cn_comp_plan_pub.Create_comp_plan
       (
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        p_commit             => p_commit,
        p_validation_level   => p_validation_level,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_comp_plan_rec      => l_comp_rec,
        x_comp_plan_id       => x_comp_plan_id,
        x_loading_status     => x_loading_status );

END create_comp_plan_client;

END CN_COMP_PLANS_PVT;

/
