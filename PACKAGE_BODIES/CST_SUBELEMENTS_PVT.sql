--------------------------------------------------------
--  DDL for Package Body CST_SUBELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_SUBELEMENTS_PVT" AS
/* $Header: CSTVCCYB.pls 120.3 2006/08/21 01:02:25 rzhu noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CST_SubElements_PVT';

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   processInterface                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serves as the wrapper that suitably creates or summarizes   --
--  subelements in the enhanced interorg cost copy program                --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE processInterface (
		p_api_version			IN	NUMBER,
	 	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE,
		p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
		p_validation_level		IN	VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

		x_return_status			OUT NOCOPY	VARCHAR2,
		x_msg_count			OUT NOCOPY	NUMBER,
		x_msg_data			OUT NOCOPY	VARCHAR2,

		p_group_id			IN	NUMBER,
		p_from_organization_id		IN	NUMBER,
		p_to_organization_id		IN	NUMBER,
		p_from_cost_type_id		IN	NUMBER,
		p_to_cost_type_id		IN	NUMBER,
                p_summary_option		IN	NUMBER,
		p_mtl_subelement		IN	NUMBER,
		p_moh_subelement		IN	NUMBER,
		p_res_subelement		IN	NUMBER,
		p_osp_subelement		IN	NUMBER,
		p_ovh_subelement		IN	NUMBER,
                p_conv_type                     IN      VARCHAR2,
                p_exact_copy_flag               IN      VARCHAR2 ) IS

  l_api_name	CONSTANT	VARCHAR2(30) := 'processInterface';
  l_api_version CONSTANT	NUMBER 	     := 1.0;

  l_return_status	VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count		NUMBER := 0;
  l_msg_data            VARCHAR2(240) := '';
  l_counter		INTEGER := 0;
  l_statement		NUMBER;

  l_subelement_tbl	nonmatching_tbl_type;
  l_department_tbl	nonmatching_tbl_type;
  l_activity_tbl	nonmatching_tbl_type;
  l_subelement_count	NUMBER := 0;
  l_department_count	NUMBER := 0;
  l_activity_count	NUMBER := 0;

  l_api_message		VARCHAR2(1000);

  BEGIN

    --  Standard Start of API savepoint
    SAVEPOINT processInterface_PVT;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
			l_api_version,
			p_api_version,
			l_api_name,
			G_PKG_NAME ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if (p_from_organization_id IS NULL OR
        p_to_organization_id IS NULL OR
        p_from_cost_type_id IS NULL OR
        p_to_cost_type_id IS NULL ) then
          RAISE fnd_api.g_exc_error;
    end if;

    -- Call API depending on summary option
    fnd_file.put_line(fnd_file.log,'Calling getNonMatchingSubElements...');

    fnd_file.put_line(fnd_file.log,'Test Message');

    getNonMatchingSubElements
              ( p_api_version 		=>	1.0,
	  	x_return_status 	=>	l_return_status,
                x_msg_count		=>	l_msg_count,
                x_msg_data		=>      l_msg_data,
                x_subelement_tbl	=>	l_subelement_tbl,
		x_department_tbl	=>	l_department_tbl,
		x_activity_tbl		=>	l_activity_tbl,
                x_subelement_count	=>	l_subelement_count,
		x_department_count	=>	l_department_count,
		x_activity_count	=>	l_activity_count,
		p_group_id		=>	p_group_id,
		p_from_organization_id	=>	p_from_organization_id,
		p_to_organization_id	=>	p_to_organization_id );


/* ***** Added by AD for error handling ***** */
    IF (x_return_status <>'S') THEN
	    fnd_file.put_line(fnd_file.log,x_msg_data);
	    l_api_message := 'Compatible_API_Call returned Error';
	    FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
      	    FND_MESSAGE.set_token('TEXT', l_api_message);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error ;
    END IF;


    -- Verify summary option
    if (p_summary_option = 1) then
         if ((l_subelement_count = 0) AND (l_department_count = 0)
              AND (l_activity_count = 0)) then
                fnd_file.put_line(fnd_file.log,'create with no nonmatching SE');
                return;
         else
	      fnd_file.put_line(fnd_file.log,'Calling createSubElements ...');
              createSubElements
               ( p_api_version 		=>	1.0,
	         p_subelement_tbl   	=>	l_subelement_tbl,
	         p_department_tbl	=>	l_department_tbl,
		 p_activity_tbl		=>	l_activity_tbl,
                 p_subelement_count 	=>	l_subelement_count,
		 p_department_count 	=>	l_department_count,
		 p_activity_count   	=>	l_activity_count,
		 p_from_organization_id =>	p_from_organization_id,
    		 p_to_organization_id 	=>	p_to_organization_id,
                 p_exact_copy_flag      =>      FND_API.G_FALSE,
		 x_return_status	=>	l_return_status,
		 x_msg_count		=>	l_msg_count,
		 x_msg_data		=>	l_msg_data );


	/* ***** Added by AD for error handling ***** */
	    IF (x_return_status <>'S') THEN
            	fnd_file.put_line(fnd_file.log,x_msg_data);
                l_api_message := 'createSubElements returned Error';
                FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
                FND_MESSAGE.set_token('TEXT', l_api_message);
            	fnd_msg_pub.add;
            	RAISE fnd_api.g_exc_error ;
            END IF;

         end if;
     elsif ((p_summary_option = 2)
             OR (p_summary_option = 3 AND l_subelement_count >= 0)) then
             fnd_file.put_line(fnd_file.log,'calling summarizeSubElements ...');
              summarizeSubElements
               ( p_api_version		=>	1.0,
		 x_return_status	=>	l_return_status,
		 x_msg_count		=>	l_msg_count,
                 x_msg_data		=>	l_msg_data,
		 p_subelement_tbl	=>	l_subelement_tbl,
		 p_subelement_count	=> 	l_subelement_count,
                 p_department_tbl	=>	l_department_tbl,
		 p_department_count	=>	l_department_count,
		 p_activity_tbl		=>	l_activity_tbl,
		 p_activity_count	=>	l_activity_count,
                 p_summary_option	=>	p_summary_option,
		 p_material_subelement  =>	p_mtl_subelement,
		 p_moh_subelement	=>	p_moh_subelement,
		 p_resource_subelement  =>	p_res_subelement,
		 p_overhead_subelement  =>	p_ovh_subelement,
		 p_osp_subelement	=>	p_osp_subelement,
		 p_from_organization_id =>	p_from_organization_id,
		 p_to_organization_id	=>	p_to_organization_id,
		 p_from_cost_type_id	=>	p_from_cost_type_id,
		 p_to_cost_type_id	=>	p_to_cost_type_id,
		 p_group_id		=>	p_group_id,
                 p_conversion_type	=>	p_conv_type );

        /* ***** Added by AD for error handling ***** */
            IF (x_return_status <>'S') THEN
                fnd_file.put_line(fnd_file.log,x_msg_data);
                l_api_message := 'summarizeSubElements returned Error';
                FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
                FND_MESSAGE.set_token('TEXT', l_api_message);
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_error ;
            END IF;

     end if;

    -- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    -- Standard Call to get message count and if count = 1, get message info
    FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );


    EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'processInterface : Statement -'||to_char(l_statement)
              );

      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           );
END processInterface;



----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getNonMatchingSubElements                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API fetched all the non-matching subelements bewteen two        --
--   organizations and returns them  in a PL/SQL table format             --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Anitha B       Created                                 --
----------------------------------------------------------------------------

PROCEDURE    getNonMatchingSubElements (
                            p_api_version                   IN      NUMBER,
                            p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                            p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,

                            x_return_status                 OUT NOCOPY     VARCHAR2,
                            x_msg_count                     OUT NOCOPY     NUMBER,
                            x_msg_data                      OUT NOCOPY     VARCHAR2,

                            x_subelement_tbl                OUT NOCOPY     nonmatching_tbl_type,
                            x_department_tbl                OUT NOCOPY     nonmatching_tbl_type,
                            x_activity_tbl                  OUT NOCOPY     nonmatching_tbl_type,
                            x_subelement_count              OUT NOCOPY     NUMBER,
                            x_department_count              OUT NOCOPY     NUMBER,
                            x_activity_count                OUT NOCOPY     NUMBER,

                            p_group_id                      IN      NUMBER,
                            p_from_organization_id          IN      NUMBER ,
                            p_to_organization_id            IN      NUMBER ) IS

 l_api_name                 CONSTANT    VARCHAR2(30)    := 'getNonMatchingSubElements';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;
 l_exists                   NUMBER;
 l_current_rec              CST_SubElements_PVT.nonmatching_rec_type;

 l_api_message		    VARCHAR2(1000);

 CURSOR C_from_subelements IS
 /* Bug 5443502: added cost_element_id in the select */
   select distinct cicdi.resource_code, cicdi.cost_element_id
   from cst_item_cst_dtls_interface cicdi
   where cicdi.group_id = p_group_id
   and cicdi.resource_code is not null
   UNION
   select distinct basis_resource_code, cost_element_id
   from cst_item_cst_dtls_interface
   where group_id = p_group_id
   and basis_resource_code is not null;

 CURSOR C_from_departments IS
   select distinct department
   from cst_item_cst_dtls_interface
   where group_id = p_group_id
   and department is not null;

 CURSOR C_from_activity IS
   select distinct activity
   from cst_item_cst_dtls_interface
   where group_id = p_group_id
   and activity is not null;


 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT getNonMatchingSubElements_PVT;

    -- Standard Call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

        -- Initiliaze API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_from_organization_id   IS NULL OR
       p_to_organization_id     IS NULL OR
       p_group_id               IS NULL)  THEN

	FND_FILE.PUT_LINE(FND_FILE.LOG,'From Org, To Org or Cost Group Info is missing');
        l_api_message := 'From Org, To Org or Cost Group Info is missing';
        FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.set_token('TEXT', l_api_message);
	FND_MSG_PUB.ADD;

        RAISE fnd_api.g_exc_error;
    END IF;

 -- Check for non matching subelements
 FOR subelement_rec IN C_from_subelements LOOP
 EXIT WHEN C_from_subelements%NOTFOUND;

   l_statement := 10;
   /* Bug 5443502: Added join with cost_element_id */
   select count(*)
   into l_exists
   from bom_resources
   where resource_code = subelement_rec.resource_code
   and cost_element_id = subelement_rec.cost_element_id
   and organization_id = p_to_organization_id;

   l_statement := 20;
   if (l_exists > 1) then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Too many resource with the same code');
        l_api_message := 'Too many resource with the same code';
        FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.set_token('TEXT', l_api_message);
        FND_MSG_PUB.ADD;

     RAISE fnd_api.g_exc_error;
   elsif (l_exists = 0) then
     l_statement := 30;
     l_current_rec.code := subelement_rec.resource_code;

     l_statement := 40;
     select resource_id
     into l_current_rec.ID
     from bom_resources
     where organization_id = p_from_organization_id
     and resource_code = l_current_rec.code;

     l_statement := 50;
     l_counter := l_counter + 1;
     x_subelement_tbl(l_counter).code := l_current_rec.code;
     x_subelement_tbl(l_counter).ID := l_current_rec.ID;
     x_subelement_tbl(l_counter).source := 'S';
   elsif (l_exists = 1) then
     l_statement := 52;
   end if;
 END LOOP;
 x_subelement_count := l_counter;

 -- Check for nonmatching departments
 l_counter := 0;
 FOR department_rec IN C_from_departments LOOP
 EXIT WHEN C_from_departments%NOTFOUND;

   l_statement := 60;
   select count(*)
   into l_exists
   from bom_departments
   where department_code = department_rec.department
   and organization_id = p_to_organization_id;

   l_statement := 70;
   if (l_exists > 1) then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Too many Dept with the same code');
        l_api_message := 'Too many Dept with the same code';
        FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.set_token('TEXT', l_api_message);
        FND_MSG_PUB.ADD;

     RAISE fnd_api.g_exc_error;
   elsif (l_exists = 0) then
     l_statement := 80;
     l_current_rec.code := department_rec.department;

     l_statement := 90;
     select department_id
     into l_current_rec.ID
     from bom_departments
     where organization_id = p_from_organization_id
     and department_code = l_current_rec.code;

     l_statement := 100;
     l_counter := l_counter + 1;
     x_department_tbl(l_counter).code := l_current_rec.code;
     x_department_tbl(l_counter).ID := l_current_rec.ID;
     x_department_tbl(l_counter).source := 'D';
   end if;
 END LOOP;
 x_department_count := l_counter;

 -- Check for nonmatching activity
 l_counter := 0;
 FOR activity_rec IN C_from_activity LOOP
 EXIT WHEN C_from_activity%NOTFOUND;

   l_statement := 110;
   select count(*)
   into l_exists
   from cst_activities
   where activity = activity_rec.activity
   and nvl(organization_id,p_to_organization_id) = p_to_organization_id;

   l_statement := 120;
   if (l_exists > 1) then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Too many Activities with the same code');
        l_api_message := 'Too many Activities with the same code';
        FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
        FND_MESSAGE.set_token('TEXT', l_api_message);
        FND_MSG_PUB.ADD;


     RAISE fnd_api.g_exc_error;
   elsif (l_exists = 0) then
     l_statement := 130;
     l_current_rec.code := activity_rec.activity;

     l_statement := 140;
     select activity_id
     into l_current_rec.ID
     from cst_activities
     where organization_id = p_from_organization_id
     and activity = l_current_rec.code;

     l_statement := 150;
     l_counter := l_counter + 1;
     x_activity_tbl(l_counter).code := l_current_rec.code;
     x_activity_tbl(l_counter).ID := l_current_rec.ID;
     x_activity_tbl(l_counter).source := 'A';
   end if;
 END LOOP;
 x_activity_count := l_counter;

 -- Standard check of p_commit
 IF FND_API.to_Boolean(p_commit) THEN
    COMMIT WORK;
 END IF;

 -- Standard Call to get message count and if count = 1, get message info
 FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'getNonMatchingSubElements : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END getNonMatchingSubElements;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   createSubElements                                                    --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API creates activities,  dept classes, departments              --
--   and subelements in an organization, from a given organization.       --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    createSubElements (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,


                   p_subelement_tbl         IN      nonmatching_tbl_type,
                   p_department_tbl         IN      nonmatching_tbl_type,
                   p_activity_tbl           IN      nonmatching_tbl_type,
                   p_subelement_count       IN      NUMBER,
                   p_department_count       IN      NUMBER,
                   p_activity_count         IN      NUMBER,
                   p_from_organization_id   IN      NUMBER ,
                   p_to_organization_id     IN      NUMBER,
                   p_exact_copy_flag        IN	    VARCHAR2,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2 ) IS

 l_api_name                 CONSTANT    VARCHAR2(30)    := 'createSubElements';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;

 l_to_wsm_flag              NUMBER;
 l_scrap_acct		    NUMBER := NULL;
 l_est_abs_acct             NUMBER := NULL;
 l_absorption_acct          NUMBER := NULL;
 l_rate_variance_acct       NUMBER := NULL;
 l_cost_element_id	    NUMBER;
 l_purchase_item_id         NUMBER;
 l_func_currency_uom        VARCHAR2(3);
 l_func_curr_flag           NUMBER;
 l_default_activity_id      NUMBER;
 l_expenditure_type         VARCHAR2(30) := NULL;
 l_exp_type_required	    NUMBER;
 l_dummy		    NUMBER;

 l_source_activity_id       NUMBER;
 l_source_department_id     NUMBER;
 l_source_resource_id       NUMBER;
 l_department_class_code    VARCHAR2(10);
 l_resource_code            VARCHAR2(10);
 l_activity                 VARCHAR2(10);
 l_department_code          VARCHAR2(10);
 l_err_code		    NUMBER := 0;
 l_err_msg		    VARCHAR2(240) := '';
 l_request_id               NUMBER ;
 l_user_id                  NUMBER ;
 l_prog_id                  NUMBER ;
 l_prog_app_id              NUMBER ;
 l_login_id                 NUMBER ;
 l_conc_program_id          NUMBER ;
 l_debug                    VARCHAR2(80) ;

 l_api_message		    VARCHAR2(1000);

 x_est_scrap_acct_flag 	   NUMBER;
 x_err_num                        NUMBER;
 x_err_msg                        VARCHAR2(200);
 BEGIN

    -------------------------------------------------------------------------
    -- Standard Start of API savepoint
    -------------------------------------------------------------------------

    SAVEPOINT createSubElements_PVT;

    -------------------------------------------------------------------------
    -- Standard Call to check for call compatibility
    -------------------------------------------------------------------------

    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------
    -- Set WHO columns
    -------------------------------------------------------------------------
    l_statement	       := 10;
    l_request_id       := FND_GLOBAL.conc_request_id;
    l_user_id          := FND_GLOBAL.user_id;
    l_prog_id          := FND_GLOBAL.conc_program_id;
    l_prog_app_id      := FND_GLOBAL.prog_appl_id;
    l_login_id         := FND_GLOBAL.conc_login_id;

    l_debug            := FND_PROFILE.VALUE('MRP_DEBUG');


    -------------------------------------------------------------------------
    -- Initiliaze API return status to success
    -------------------------------------------------------------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    l_statement := 20;

    IF(p_from_organization_id   IS NULL OR
       p_to_organization_id     IS NULL ) THEN

        RAISE fnd_api.g_exc_error;

    END IF;

    ----------------------------------------------------------------------
    -- cst_activities
    ----------------------------------------------------------------------
    FND_FILE.PUT_LINE(FND_FILE.LOG,'activity count : '
      || TO_CHAR(p_activity_count));

    FOR l_counter IN  1..p_activity_count
    LOOP

      l_statement := 30;

      l_source_activity_id     := p_activity_tbl( l_counter).ID;

      l_statement := 40;

      SELECT MAX(activity)
      INTO   l_activity
      FROM   cst_activities ca
      WHERE  ca.activity_id = l_source_activity_id
      AND    ca.organization_id = p_from_organization_id;


      ------------------------------------------------------------------------
      -- Create activity only if the source activity id is not multi-org
      -- i.e. it is org specific and therefore must be created in the to_org
      -- if it already does not exist
      -- The above SQL will return NULL in variable l_activity if
      -- the l_source_activity_id is multi-org
      -- The INSERT statement will check specifically for the from_org_id
      -- when creating a row in to_org
      ------------------------------------------------------------------------

      l_statement := 50;

      INSERT INTO cst_activities
      (
        activity_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        activity,
        organization_id,
        description,
        default_basis_type,
        disable_date,
        output_uom,
        value_added_activity_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        request_id,
        program_application_id,
        program_id,
        program_update_date
       )
       SELECT
        cst_activities_s.nextval,
        SYSDATE,
        l_user_id,
        SYSDATE,
        l_user_id,
        l_login_id,
        activity,
        p_to_organization_id,
        description,
        default_basis_type,
        disable_date,
        output_uom,
        value_added_activity_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        l_request_id,
        l_prog_app_id,
        l_prog_id,
        SYSDATE
       FROM  cst_activities ca
       WHERE ca.activity_id = l_source_activity_id
       AND   ca.organization_id = p_from_organization_id
       AND NOT EXISTS  ( SELECT  'X'
                         FROM    cst_activities ca2
                         WHERE   ca2.organization_id = p_to_organization_id
                         AND     ca2.activity = l_activity) ;

       IF (SQL%ROWCOUNT) > 0 THEN

         FND_FILE.PUT_LINE(FND_FILE.LOG, l_activity || ' Activity created.');

       END IF;

    END LOOP;

    l_statement := 60;

    -- departments
    fnd_file.put_line(fnd_file.log,'dept count : ' || to_char(p_department_count));

    if (p_department_count > 0) then

      l_statement := 70;

      -- set to wsm org flag

      SELECT  COUNT(*)
      INTO    l_to_wsm_flag
      FROM    mtl_parameters mp, wsm_parameters wsm
      WHERE   wsm.organization_id = p_to_organization_id
      AND     mp.organization_id = wsm.organization_id
      AND     UPPER(mp.wsm_enabled_flag)='Y';

      /* -- commenting to avoid dependency on WSMPUTIL. Make sure
         -- WSM_PARAMETERS tables exists in 11.5.1 otherwise we will
         -- have to include the odf
      l_to_wsm_flag :=  WSMPUTIL.check_wsm_org(
                            p_organization_id => p_to_organization_id,
                            x_err_code => l_err_code,
                            x_err_msg  =>  l_err_msg);
      */

      IF (l_to_wsm_flag > 0) THEN
            l_to_wsm_flag := 1;
      ELSE
            l_to_wsm_flag := -1;
      END IF;

    END IF;

    l_statement := 80;

    FOR l_counter IN  1..p_department_count LOOP

      l_statement := 90;

      l_source_department_id := p_department_tbl( l_counter).ID;

      l_statement := 100;

      IF  p_exact_copy_flag = FND_API.G_FALSE THEN

        IF (l_to_wsm_flag = 1) THEN

          FND_FILE.PUT_LINE(FND_FILE.LOG, '>>getDeptAccounts()');

          getDeptAccounts(
                    p_api_version            =>  1,
                    p_department_id          =>  l_source_department_id,
                    p_from_organization_id   =>  p_from_organization_id,
                    p_to_organization_id     =>  p_to_organization_id,
                    x_scrap_account          =>  l_scrap_acct,
                    x_est_absorption_account =>  l_est_abs_acct,
                    x_return_status          =>  x_return_status,
                    x_msg_count              =>  x_msg_count,
                    x_msg_data               =>  x_msg_data );

          FND_FILE.PUT_LINE(FND_FILE.LOG, '<<getDeptAccounts()');

          IF (x_return_status =  fnd_api.g_ret_sts_error) THEN
            fnd_message.set_name('BOM', 'CST_DEPT_ACCOUNTS_NULL');
            fnd_message.set_token('DEPT_CODE',p_department_tbl( l_counter).CODE,TRUE);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error ;
          END IF;

          IF (x_return_status =  fnd_api.g_ret_sts_unexp_error) THEN
            fnd_message.set_name('BOM', 'CST_DEPT_ACCOUNTS_NULL');
            fnd_message.set_token('DEPT_CODE',p_department_tbl( l_counter).CODE,TRUE);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error ;
          END IF;

        END IF; --check for wsm flag

      ELSE  -- exact copy is true, use ccid from the source org

        l_statement := 110;

        SELECT  scrap_account,
                est_absorption_account
        INTO    l_scrap_acct,
                l_est_abs_acct
        FROM    bom_departments bd
        WHERE   bd.department_id = l_source_department_id;


      END IF; --check for p_exact_copy_flag

      l_statement := 115;

      IF l_to_wsm_flag = 1 THEN

        x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(
                                   NULL,x_err_num, x_err_msg,p_from_organization_id);

        fnd_file.put_line(fnd_file.log,'Estimated Scrap Accounting Flag: '||x_est_scrap_acct_flag);

        IF (x_est_scrap_acct_flag = 0) THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        l_statement := 120;

        IF x_est_scrap_acct_flag = 1 AND
           (l_scrap_acct IS NULL OR l_est_abs_acct IS NULL) THEN
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF;

      ----------------------------------------------------------------------
      -- Create Department Class code if it does not exist
      ----------------------------------------------------------------------

      l_statement := 130;

      SELECT  department_class_code,
              department_code
      INTO    l_department_class_code,
              l_department_code
      FROM    bom_departments bd
      WHERE   bd.organization_id = p_from_organization_id
      AND     bd.department_id = l_source_department_id;

      l_statement := 140;

      IF (l_department_class_code IS NOT NULL) THEN

        INSERT INTO bom_department_classes
        (
          department_class_code,
          organization_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          description,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          request_id,
          program_application_id,
          program_id,
          program_update_date
       )
       SELECT
          department_class_code,
          p_to_organization_id,
          SYSDATE,
          l_user_id,
          SYSDATE,
          l_user_id,
          l_login_id,
          description,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          l_request_id,
          l_prog_app_id,
          l_prog_id,
          SYSDATE
       FROM  bom_department_classes bdc
       WHERE bdc.organization_id = p_from_organization_id
       AND   bdc.department_class_code = l_department_class_code
       AND NOT EXISTS
          (  SELECT  'X'
             FROM    bom_department_classes bdc2
             WHERE   bdc2.organization_id = p_to_organization_id
             AND     bdc2.department_class_code = l_department_class_code);

       IF (SQL%ROWCOUNT) > 0 THEN

         FND_FILE.PUT_LINE(FND_FILE.LOG, l_department_class_code ||
                           ' Department class code created.');

       END IF;

      END IF;    -- check for dept class code NOT NULL


      l_statement := 150;


      ----------------------------------------------------------------------
      -- Create the department
      -- How do we ensure that location id is valid for to_org?
      ----------------------------------------------------------------------

      INSERT INTO bom_departments
      (
        department_id,
        department_code,
        organization_id,
        last_update_date,
        last_updated_by,
	creation_date,
        created_by,
        last_update_login,
        description,
        disable_date,
        department_class_code,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        location_id,
        pa_expenditure_org_id,
        scrap_account,
        est_absorption_account
        )
      SELECT
        bom_departments_s.nextval,
        department_code,
        p_to_organization_id,
        SYSDATE,
        l_user_id,
	SYSDATE,
        l_user_id,
        l_login_id,
        description,
        disable_date,
        department_class_code,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        l_request_id,
        l_prog_app_id,
        l_prog_id,
        SYSDATE,
        location_id,
        pa_expenditure_org_id,
        decode(l_to_wsm_flag, 1, l_scrap_acct, NULL),
        decode(l_to_wsm_flag, 1, l_est_abs_acct, NULL)
      FROM  bom_departments
      WHERE organization_id = p_from_organization_id
      AND   department_id = l_source_department_id
      AND  NOT EXISTS  (SELECT  'X'
                        FROM    bom_departments bd2
                        WHERE   bd2.organization_id = p_to_organization_id
                        AND     bd2.department_code = l_department_code);

      IF (SQL%ROWCOUNT) > 0 THEN

         FND_FILE.PUT_LINE(FND_FILE.LOG, l_department_code ||
                           ' Department code created.');

      END IF;

    END LOOP;

    ------------------------------------------------------------------------
    -- bom_resources
    ------------------------------------------------------------------------

    l_statement := 160;

    IF (p_subelement_count > 0) THEN

      SELECT  decode(project_reference_enabled,1,
                decode(pm_cost_collection_enabled,1,1,0),0)
      INTO    l_exp_type_required
      FROM    mtl_parameters
      WHERE   organization_id = p_to_organization_id;

      l_statement := 170;

      SELECT SubStr(currency_code,1,3)
      INTO    l_func_currency_uom
      FROM gl_sets_of_books gsob,
           hr_organization_information hoi
      WHERE hoi.organization_id = p_to_organization_id
      AND   hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
      AND   gsob.set_of_books_id = hoi.org_information1 ;


    END IF;

    fnd_file.put_line(fnd_file.log,'subelement count : ' ||
                               to_char(p_subelement_count));

    FOR l_counter IN  1..p_subelement_count LOOP

      l_statement := 180;

      l_source_resource_id := p_subelement_tbl( l_counter).ID;
       fnd_file.put_line(fnd_file.log,'subelement(' || to_char(l_counter) || '): ' || to_char(l_source_resource_id));

      l_statement := 190;
      SELECT  cost_element_id,
              purchase_item_id,
              functional_currency_flag,
              default_activity_id,
              expenditure_type,
              absorption_account,
              rate_variance_account,
              resource_code
      INTO    l_cost_element_id,
              l_purchase_item_id,
              l_func_curr_flag,
              l_default_activity_id,
              l_expenditure_type,
              l_absorption_acct,
              l_rate_variance_acct,
              l_resource_code
      FROM    bom_resources br
      WHERE   br.organization_id = p_from_organization_id
      AND     br.resource_id = l_source_resource_id;

      -------------------------------------------------------------------------
      -- Get OSP item
      -- exact copy callers should ensure that OSP Item exists in the
      -- destination organization for the OSP resource before invoking this API
      -------------------------------------------------------------------------

      IF l_cost_element_id = 4 THEN

        l_statement := 200;

        SELECT  MAX(msi.inventory_item_id)
        INTO    l_dummy
        FROM    mtl_system_items msi
        WHERE   msi.inventory_item_id =  l_purchase_item_id
        AND     msi.organization_id   =  p_to_organization_id;

        l_statement := 210;

        IF l_dummy IS NULL THEN
          l_purchase_item_id := NULL;

          FND_FILE.PUT_LINE(FND_FILE.LOG,'>>getOSPitem()');

          getOSPItem (
                    p_api_version            =>  1,
                    p_resource_id            =>  l_source_resource_id,
                    p_from_organization_id   =>  p_from_organization_id,
                    p_to_organization_id     =>  p_to_organization_id,
                    x_item_id                =>  l_purchase_item_id,
                    x_return_status          =>  x_return_status,
                    x_msg_count              =>  x_msg_count,
                    x_msg_data               =>  x_msg_data );

          FND_FILE.PUT_LINE(FND_FILE.LOG,'<<getOSPitem()');

          IF (x_return_status =  fnd_api.g_ret_sts_error) THEN
            fnd_message.set_name('BOM', 'CST_PURCHASE_ITEM_ERROR');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error ;
          END IF;

          IF (x_return_status =  fnd_api.g_ret_sts_unexp_error) THEN
            fnd_message.set_name('BOM', 'CST_PURCHASE_ITEM_ERROR');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error ;
          END IF;


        END IF;

        -----------------------------------------------------------------------
        -- Purchase item id should be mandatory for OSP resource?
        -- Currently we ust display a Warning and create the OSP Res
        -- without the OSP item.
        -----------------------------------------------------------------------

        IF l_purchase_item_id IS NULL THEN
            fnd_message.set_name('BOM', 'CST_PURCHASE_ITEM_NULL');
            fnd_message.set_token('RESOURCE_CODE',p_subelement_tbl( l_counter).CODE,TRUE);
            fnd_msg_pub.add;

          FND_FILE.PUT_LINE(FND_FILE.LOG,
                'WARNING: OSP Item is missing for Res_id: '
                ||TO_CHAR(l_source_resource_id));
          --RAISE fnd_api.g_exc_error;
        END IF;

      END IF; -- check for CE=4 (OSP)

      -------------------------------------------------------------------------
      -- Get Default Activity
      -- Calling modules  should ensure that default activity has been included
      -- in the activity parameter table
      -------------------------------------------------------------------------

      IF (l_default_activity_id IS NOT NULL) THEN
     	      l_statement := 220;

              SELECT  MAX(activity_id)
              INTO    l_dummy
              FROM    cst_activities ca
              WHERE   ca.activity =
                        ( SELECT ca2.activity
                          FROM   cst_activities ca2
                          WHERE  ca2.activity_id = l_default_activity_id)
              AND      (ca.organization_id = p_to_organization_id OR
                       ca.organization_id IS NULL);

          l_statement := 230;

          IF  l_dummy IS NULL THEN

              l_default_activity_id := NULL;

              FND_FILE.PUT_LINE(FND_FILE.LOG,'>>getDefaultActivity()');

              getDefaultActivity (
                    p_api_version            =>  1,
                    p_resource_id            =>  l_source_resource_id,
                    p_from_organization_id   =>  p_from_organization_id,
                    p_to_organization_id     =>  p_to_organization_id,
                    x_activity_id            =>  l_default_activity_id,
                    x_return_status          =>  x_return_status,
                    x_msg_count              =>  x_msg_count,
                    x_msg_data               =>  x_msg_data );

              FND_FILE.PUT_LINE(FND_FILE.LOG,'<<getDefaultActivity()');

              IF (x_return_status =  fnd_api.g_ret_sts_error) THEN
                    fnd_message.set_name('BOM', 'CST_NO_DEFAULT_ACTIVITY');
                    fnd_message.set_token('RESOURCE_CODE',p_subelement_tbl( l_counter).CODE,TRUE);
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error ;
              END IF;

              IF (x_return_status =  fnd_api.g_ret_sts_unexp_error) THEN
                    fnd_message.set_name('BOM', 'CST_NO_DEFAULT_ACTIVITY');
                    fnd_message.set_token('RESOURCE_CODE',p_subelement_tbl( l_counter).CODE,TRUE);
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error ;
              END IF;
          ELSE
              l_default_activity_id := l_dummy;
          END IF;

          IF l_default_activity_id IS NULL THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Default Activity is null');
              RAISE fnd_api.g_exc_error;
          END IF;

      END IF; /* default activity in from org is not null */

      -------------------------------------------------------------------------
      -- Get Expenditure type
      -- For Exact Copy, l_expenditure_type will be NOT NULL
      -------------------------------------------------------------------------

      l_statement := 240;

      IF (l_exp_type_required = 1 AND l_expenditure_type IS NULL) THEN

        FND_FILE.PUT_LINE(FND_FILE.LOG,'>>getExpenditureType()');

        getExpenditureType (
                    p_api_version            =>  1,
                    p_resource_id            =>  l_source_resource_id,
                    p_from_organization_id   =>  p_from_organization_id,
                    p_to_organization_id     =>  p_to_organization_id,
                    x_expenditure_type       =>  l_expenditure_type,
                    x_return_status          =>  x_return_status,
                    x_msg_count              =>  x_msg_count,
                    x_msg_data               =>  x_msg_data );

        FND_FILE.PUT_LINE(FND_FILE.LOG,'<<getExpenditureType()');

        IF (x_return_status =  fnd_api.g_ret_sts_error) THEN
          fnd_message.set_name('BOM', 'CST_EXPENDITURE_TYPE_NULL');
          fnd_message.set_token('RESOURCE_CODE',p_subelement_tbl( l_counter).CODE,TRUE);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error ;
        END IF;

        IF (x_return_status =  fnd_api.g_ret_sts_unexp_error) THEN
          fnd_message.set_name('BOM', 'CST_EXPENDITURE_TYPE_NULL');
          fnd_message.set_token('RESOURCE_CODE',p_subelement_tbl( l_counter).CODE,TRUE);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error ;
        END IF;

        IF (l_expenditure_type IS NULL) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Expenditure type is null');
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      -------------------------------------------------------------------------
      -- Get Absorption and rate Variance Accounts for non-material subelements
      -------------------------------------------------------------------------

      IF (l_cost_element_id <> 1) THEN

        IF p_exact_copy_flag  = FND_API.G_FALSE THEN

          l_absorption_acct    := NULL;
          l_rate_variance_acct := NULL;

          l_statement := 250;

          FND_FILE.PUT_LINE(FND_FILE.LOG,'>>getSubelementAcct()');

          getSubelementAcct (
                    p_api_version            =>  1,
                    p_resource_id            =>  l_source_resource_id,
                    p_from_organization_id   =>  p_from_organization_id,
                    p_to_organization_id     =>  p_to_organization_id,
                    x_absorption_account     =>  l_absorption_acct,
                    x_rate_variance_account  =>  l_rate_variance_acct,
                    x_return_status          =>  x_return_status,
                    x_msg_count              =>  x_msg_count,
                    x_msg_data               =>  x_msg_data );

          FND_FILE.PUT_LINE(FND_FILE.LOG,'<<getSubelementAcct()');

          IF (x_return_status =  fnd_api.g_ret_sts_error) THEN
            fnd_message.set_name('BOM', 'CST_SUBELEMENT_ACCTS_NULL');
            fnd_message.set_token('RESOURCE_CODE',p_subelement_tbl( l_counter).CODE,TRUE);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error ;
          END IF;

          IF (x_return_status =  fnd_api.g_ret_sts_unexp_error) THEN
             fnd_message.set_name('BOM', 'CST_SUBELEMENT_ACCTS_NULL');
             fnd_message.set_token('RESOURCE_CODE',p_subelement_tbl( l_counter).CODE,TRUE);
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_unexpected_error ;
          END IF;

        END IF; -- check for exact copy

        ----------------------------------------------------------------------
        -- Rate Variance account is not mandatory but abs account is mandatory
        ----------------------------------------------------------------------

        IF (l_absorption_acct IS NULL ) THEN

          RAISE fnd_api.g_exc_error;

        END IF;

      END IF;  -- Check for non-material subelement

      l_statement := 260;

      INSERT INTO bom_resources
      (
        resource_id,
        resource_code,
        organization_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        description,
        disable_date,
        cost_element_id,
        purchase_item_id,
        cost_code_type,
        functional_currency_flag,
        unit_of_measure,
        default_activity_id,
        resource_type,
        autocharge_type,
        standard_rate_flag,
        default_basis_type,
        absorption_account,
        allow_costs_flag,
        rate_variance_account,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        expenditure_type
        )
       SELECT
        bom_resources_s.nextval,
        resource_code,
        p_to_organization_id,
        SYSDATE,
        l_user_id,
        SYSDATE,
        l_user_id,
        l_login_id,
        description,
        disable_date,
        cost_element_id,
        l_purchase_item_id,
        cost_code_type,
        functional_currency_flag,
        decode(cost_element_id,    /* Bug 4360688: Stamp target organization's functional currency for overheads */
               2, l_func_currency_UOM,
               5, l_func_currency_UOM,
               Decode(functional_currency_flag,1,l_func_currency_uom,
                            unit_of_measure)),
        l_default_activity_id,
        resource_type,
        autocharge_type,
        standard_rate_flag,
        default_basis_type,
        l_absorption_acct,
        allow_costs_flag,
        l_rate_variance_acct,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        l_request_id,
        l_prog_app_id,
        l_prog_id,
        SYSDATE,
        l_expenditure_type
      FROM bom_resources br
      WHERE br.resource_id = l_source_resource_id
      AND   br.organization_id = p_from_organization_id
      AND NOT EXISTS  (SELECT 'X'
                       FROM   bom_resources br2
                       WHERE  br2.organization_id = p_to_organization_id
                       AND    br2.resource_code = l_resource_code);

     fnd_file.put_line(fnd_file.log,'counter : ' || to_char(l_counter));

      IF (SQL%ROWCOUNT) > 0 THEN

         FND_FILE.PUT_LINE(FND_FILE.LOG, l_resource_code ||
                           ' Resource code created.');

      END IF;

    END LOOP;

    l_statement := 270;


    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'createSubElements : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END createSubElements;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getDeptAccounts                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning department
--   accounts if the organization is WSM enabled.                         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getDeptAccounts (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                   p_department_id	    IN	    NUMBER,
                   p_from_organization_id   IN	    NUMBER,
                   p_to_organization_id     IN	    NUMBER,
                   x_scrap_account	    OUT NOCOPY     NUMBER,
                   x_est_absorption_account OUT NOCOPY	    NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) IS


 l_api_name                 CONSTANT    VARCHAR2(30)    := 'getDeptAccounts';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;

 BEGIN

    -------------------------------------------------------------------------
    -- Standard Call to check for call compatibility
    -------------------------------------------------------------------------

    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------
    -- Initiliaze API return status to success
    -------------------------------------------------------------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    ---------------------------------------------------------------------------
    -- Place Extension code here
    -- The default code will return the organization's expense account as the
    -- scrap and Estimated Absorption account.
    -- Change this to suit business functionality!
    ---------------------------------------------------------------------------
    l_statement := 10;

    SELECT  mp.expense_account,
            mp.expense_account
    INTO    x_scrap_account,
            x_est_absorption_account
    FROM    mtl_parameters mp
    WHERE   mp.organization_id = p_to_organization_id;


    ---------------------------------------------------------------------------
    -- Standard check of p_commit
    ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    --------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    --------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'getDeptAccounts : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END getDeptAccounts;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getOSPItem                                                           --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning OSP item id      --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getOSPItem (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                   p_resource_id	    IN	    NUMBER,
                   p_from_organization_id   IN      NUMBER,
                   p_to_organization_id	    IN	    NUMBER,

                   x_item_id	            OUT NOCOPY     NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) IS


 l_api_name                 CONSTANT    VARCHAR2(30)    := 'getOSPItem';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;

 BEGIN

    -------------------------------------------------------------------------
    -- Standard Call to check for call compatibility
    -------------------------------------------------------------------------

    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------
    -- Initiliaze API return status to success
    -------------------------------------------------------------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------------------------------
    -- Place Extension code here
    -------------------------------------------------------------------------

    -------------------------------------------------------------------------
    -- Standard check of p_commit
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    -------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'getOSPItem : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END getOSPItem;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getDefaultActivity                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning                  --
--   default activity for a given subelement                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getDefaultActivity (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,

                   p_resource_id	    IN	    NUMBER,
                   p_from_organization_id   IN	    NUMBER,
                   p_to_organization_id     IN	    NUMBER,
                   x_activity_id	    OUT NOCOPY     NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) IS


 l_api_name                 CONSTANT    VARCHAR2(30)    := 'getDefaultActivity';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;

 BEGIN

    -------------------------------------------------------------------------
    -- Standard Call to check for call compatibility
    -------------------------------------------------------------------------

    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------
    -- Initiliaze API return status to success
    -------------------------------------------------------------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------------------------------
    -- Place Extension code here
    -------------------------------------------------------------------------

    -------------------------------------------------------------------------
    -- Standard check of p_commit
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    -------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'getDefaultActivity : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END getDefaultActivity;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getExpenditureType                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning                  --
--   Expenditure Type for a given subelement                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getExpenditureType (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,

                   p_resource_id	    IN	    NUMBER,
                   p_from_organization_id   IN	    NUMBER,
                   p_to_organization_id     IN	    NUMBER,
                   x_expenditure_type	    OUT NOCOPY     VARCHAR2,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) IS


 l_api_name                 CONSTANT    VARCHAR2(30)    := 'getExpenditureType';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;

 BEGIN

    -------------------------------------------------------------------------
    -- Standard Call to check for call compatibility
    -------------------------------------------------------------------------

    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------
    -- Initiliaze API return status to success
    -------------------------------------------------------------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------------------------------
    -- Place Extension code here
    -- The default code will return random expenditure type for
    -- the type of subelement.
    -- Modify this code to suit business functionality!
    -------------------------------------------------------------------------

    l_statement := 10;

    SELECT  MAX(expenditure_type)
    INTO    x_expenditure_type
    FROM    cst_proj_exp_types_val_v
    WHERE   cost_element_id =
               (  SELECT br.cost_element_id
                  FROM   bom_resources br
                  WHERE  br.resource_id = p_resource_id);

    -------------------------------------------------------------------------
    -- Standard check of p_commit
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    -------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'getExpenditureType : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END getExpenditureType;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getSubelementAcct                                                    --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API serevs as a client extension for returning                  --
--   Abosorption and rate variance account for a given subelement         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Hemant Gosain    Created                               --
----------------------------------------------------------------------------

PROCEDURE    getSubelementAcct (
                   p_api_version            IN      NUMBER,
                   p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
                   p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
                   p_validation_level       IN      NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,

                   p_resource_id	    IN	    NUMBER,
                   p_from_organization_id   IN      NUMBER,
                   p_to_organization_id	    IN	    NUMBER,
                   x_absorption_account     OUT NOCOPY     NUMBER,
                   x_rate_variance_account  OUT NOCOPY     NUMBER,
                   x_return_status          OUT NOCOPY     VARCHAR2,
                   x_msg_count              OUT NOCOPY     NUMBER,
                   x_msg_data               OUT NOCOPY     VARCHAR2) IS


 l_api_name                 CONSTANT    VARCHAR2(30)    := 'getSubelementAcct';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                  INTEGER := 0;
 l_statement                NUMBER;


 l_api_message		    VARCHAR2(1000);

 BEGIN

    -------------------------------------------------------------------------
    -- Standard Call to check for call compatibility
    -------------------------------------------------------------------------

    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- Initialize message list if p_init_msg_list is set to TRUE
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -------------------------------------------------------------------------
    -- Initiliaze API return status to success
    -------------------------------------------------------------------------

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------------------------------
    -- Place Extension code here
    -- The default code will return organization level element accounts
    -- and organization expense account for absorption and variance accts.
    -- Modify this logic to suit business functionality!
    -------------------------------------------------------------------------

    l_statement := 10;

    SELECT   decode(br.cost_element_id,
                     2, mp.material_overhead_account,
                     3, mp.resource_account,
                     4, mp.outside_processing_account,
                     5, overhead_account,
                     mp.expense_account),
             mp.expense_account
    INTO     x_absorption_account,
             x_rate_variance_account
    FROM     mtl_parameters mp,
             bom_resources br
    WHERE    mp.organization_id = p_to_organization_id
    AND      br.resource_id = p_resource_id;

    -------------------------------------------------------------------------
    -- Standard check of p_commit
    -------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    -------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );


 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'getSubelementAcct : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END getSubelementAcct;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   summarizeSubElements                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API summarizes subelements into a single Item Basis type default--
--   subelements per cost element for all non-matching subelements between--
--    two organizations                                                   --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.3                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    09/14/00     Anirban Dey    Created                                 --
----------------------------------------------------------------------------

PROCEDURE    summarizeSubElements (
                            p_api_version                   IN      NUMBER,
                            p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
                            p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,

                            x_return_status                 OUT NOCOPY     VARCHAR2,
                            x_msg_count                     OUT NOCOPY     NUMBER,
                            x_msg_data                      OUT NOCOPY     VARCHAR2,

                            p_subelement_tbl                IN      nonmatching_tbl_type,
                            p_subelement_count              IN      NUMBER,
			    p_department_tbl		    IN      nonmatching_tbl_type,
			    p_department_count		    IN 	    NUMBER,
			    p_activity_tbl		    IN      nonmatching_tbl_type,
			    p_activity_count		    IN	    NUMBER,
                            p_summary_option		    IN	    NUMBER,
                            p_material_subelement           IN      NUMBER,
                            p_moh_subelement                IN      NUMBER,
                            p_resource_subelement           IN      NUMBER,
                            p_overhead_subelement           IN      NUMBER,
                            p_osp_subelement                IN      NUMBER,
                            p_from_organization_id          IN      NUMBER ,
                            p_to_organization_id            IN      NUMBER ,
                            p_from_cost_type_id             IN      NUMBER ,
                            p_to_cost_type_id               IN      NUMBER ,
                            p_group_id                      IN      NUMBER ,
                            p_conversion_type               IN      VARCHAR2 ) IS

 l_api_name                 CONSTANT    VARCHAR2(30)    := 'summarizeSubElements';
 l_api_version              CONSTANT    NUMBER          := 1.0;

 l_return_status                        VARCHAR2(1) := fnd_api.g_ret_sts_success;
 l_counter                              INTEGER := 0;
 l_statement                            NUMBER;

 l_resource_code                        VARCHAR2(10);
 l_dept_code				VARCHAR2(10);
 l_activity_code			VARCHAR2(10);

 l_material_subelement_code           VARCHAR2(10);
 l_moh_subelement_code                VARCHAR2(10);
 l_resource_subelement_code           VARCHAR2(10);
 l_overhead_subelement_code           VARCHAR2(10);
 l_osp_subelement_code                VARCHAR2(10);

 l_mat_activity                       VARCHAR2(10);
 l_moh_activity                       VARCHAR2(10);
 l_res_activity                       VARCHAR2(10);
 l_osp_activity                       VARCHAR2(10);
 l_ovh_activity                       VARCHAR2(10);

 l_primary_cost_method		      NUMBER;
 l_miss_def_subelem		      NUMBER;

 l_api_message			      VARCHAR2(1000);

 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT summarizeSubElements_PVT;

    -- Standard Call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

        -- Initiliaze API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF(p_from_organization_id   IS NULL OR
       p_to_organization_id     IS NULL OR
       p_from_cost_type_id      IS NULL OR
       p_to_cost_type_id        IS NULL OR
       p_group_id               IS NULL )  THEN

        RAISE fnd_api.g_exc_error;
    END IF;

  /* ***** intitialize all the codes values to NULL **** */
 l_material_subelement_code	:= NULL;
 l_moh_subelement_code		:= NULL;
 l_resource_subelement_code	:= NULL;
 l_overhead_subelement_code	:= NULL;
 l_osp_subelement_code		:= NULL;




    l_statement := 40;
    if (p_material_subelement > 0) then
    	SELECT  BR.RESOURCE_CODE,
            	CA.ACTIVITY
    	INTO    l_material_subelement_code,
            	l_mat_activity
    	FROM    BOM_RESOURCES   BR,
            	CST_ACTIVITIES  CA
    	WHERE   BR.RESOURCE_ID          = p_material_subelement
    	AND     BR.DEFAULT_ACTIVITY_ID  = CA.ACTIVITY_ID (+);
    end if;

    l_statement := 50;
    if (p_moh_subelement > 0) then
    	SELECT  BR.RESOURCE_CODE,
            	CA.ACTIVITY
    	INTO    l_moh_subelement_code,
            	l_moh_activity
    	FROM    BOM_RESOURCES   BR,
            	CST_ACTIVITIES  CA
    	WHERE   BR.RESOURCE_ID          = p_moh_subelement
    	AND     BR.DEFAULT_ACTIVITY_ID  = CA.ACTIVITY_ID (+);
    end if;

    l_statement := 60;
    if (p_resource_subelement > 0) then
    	SELECT  BR.RESOURCE_CODE,
            	CA.ACTIVITY
    	INTO    l_resource_subelement_code,
            	l_res_activity
    	FROM    BOM_RESOURCES   BR,
            	CST_ACTIVITIES  CA
    	WHERE   BR.RESOURCE_ID          = p_resource_subelement
    	AND     BR.DEFAULT_ACTIVITY_ID  = CA.ACTIVITY_ID (+);
    end if;

    l_statement := 70;
    if (p_osp_subelement > 0) then
    	SELECT  BR.RESOURCE_CODE,
            	CA.ACTIVITY
    	INTO    l_osp_subelement_code,
            	l_osp_activity
    	FROM    BOM_RESOURCES   BR,
            	CST_ACTIVITIES  CA
    	WHERE   BR.RESOURCE_ID          = p_osp_subelement
    	AND     BR.DEFAULT_ACTIVITY_ID  = CA.ACTIVITY_ID (+);
    end if;

    l_statement := 80;
    if (p_overhead_subelement > 0) then
    	SELECT  BR.RESOURCE_CODE,
            	CA.ACTIVITY
    	INTO    l_overhead_subelement_code,
            	l_ovh_activity
    	FROM    BOM_RESOURCES   BR,
            	CST_ACTIVITIES  CA
    	WHERE   BR.RESOURCE_ID          = p_overhead_subelement
    	AND     BR.DEFAULT_ACTIVITY_ID  = CA.ACTIVITY_ID (+);
    end if;

 IF (p_summary_option = 3) THEN

  fnd_file.put_line(fnd_file.log,'subelement_count : ' || to_char(p_subelement_count));

    FOR l_counter IN  1..p_subelement_count LOOP

    -- Obtain the cost subelement name
    l_statement := 90;

    l_resource_code     := p_subelement_tbl( l_counter).code;
    fnd_file.put_line(fnd_file.log,'resource(' || to_char(l_counter) || '): ' || l_resource_code);

    l_statement := 100;

    -- Convert to Item Basis Type for non-matching subelements
    -- Update the resource_id and resource_code to -1 for future deletion

    UPDATE      CST_ITEM_CST_DTLS_INTERFACE CICDI
    SET
                operation_sequence_id   =   NULL,   --operation_sequence_id,
                operation_seq_num       =   NULL,   --operation_seq_num,
                department_id           =   NULL,   --department_id,
                activity_id             =   NULL,   --activity_id,
                resource_seq_num        =   NULL,   --resource_seq_num,
                resource_id             =   -1,     --resource_id,
                resource_rate           =   1,      -- resource_rate
                usage_rate_or_amount    =   CICDI.item_cost,
                                                    -- usage_rate_or_amount
                basis_type              =   1,      --basis_type, -- Always Item Based
                basis_resource_id       =   NULL,   --basis_resource_id,
                basis_factor            =   1,      --basis_factor, -- Always Item Based
                item_cost               =   CICDI.item_cost,
                                                    -- item cost
                rollup_source_type      =   1,      -- rollup_source_type = Always user-defined
                activity_context        =   NULL,   --activity_context,
                department              =   NULL,   -- department
                activity                =   NULL,   -- activity
                resource_code           =   '-1',   -- resource_code
                basis_resource_code     =   NULL    -- basis_resource_code

    WHERE       CICDI.group_id      = p_group_id
    AND         CICDI.resource_code = l_resource_code;

  END LOOP;

/* Nonmatching rows imply those with matching subelements but nonmatching departments and activities */
  fnd_file.put_line(fnd_file.log,'dept count : ' || to_char(p_department_count));
  FOR l_counter IN  1..p_department_count LOOP

    -- Obtain the department name
    l_statement := 102;
    l_dept_code     := p_department_tbl( l_counter).code;
    fnd_file.put_line(fnd_file.log,'dept(' || to_char(l_counter) || '): ' || l_dept_code);

    l_statement := 104;
    -- Convert to Item Basis Type
    -- Update the resource_id and resource_code to -1 for future deletion

    UPDATE      CST_ITEM_CST_DTLS_INTERFACE CICDI
    SET
                operation_sequence_id   =   NULL,   --operation_sequence_id,
                operation_seq_num       =   NULL,   --operation_seq_num,
                department_id           =   NULL,   --department_id,
                activity_id             =   NULL,   --activity_id,
                resource_seq_num        =   NULL,   --resource_seq_num,
                resource_id             =   -1,     --resource_id,
                resource_rate           =   1,      -- resource_rate
                usage_rate_or_amount    =   CICDI.item_cost,
                                                    -- usage_rate_or_amount
                basis_type              =   1,      --basis_type, -- Always Item Based
                basis_resource_id       =   NULL,   --basis_resource_id,
                basis_factor            =   1,      --basis_factor, -- Always Item Based
                item_cost               =   CICDI.item_cost,
                                                    -- item cost
                rollup_source_type      =   1,      -- rollup_source_type = Always user-defined
                activity_context        =   NULL,   --activity_context,
                department              =   NULL,   -- department
                activity                =   NULL,   -- activity
                resource_code           =   '-1',   -- resource_code
                basis_resource_code     =   NULL    -- basis_resource_code

    WHERE       CICDI.group_id      = p_group_id
    AND         CICDI.department = l_dept_code
    AND         nvl(CICDI.resource_code,'0') <> '-1';

  END LOOP;

  fnd_file.put_line(fnd_file.log,'activity count : ' || to_char(p_activity_count));
  FOR l_counter IN  1..p_activity_count LOOP

    -- Obtain the activity name
    l_statement := 106;
    l_activity_code     := p_activity_tbl( l_counter).code;
    fnd_file.put_line(fnd_file.log,'activity(' || to_char(l_counter) || '): ' || l_activity_code);

    l_statement := 108;

    -- Convert to Item Basis Type for non-matching subelements
    -- Update the resource_id and resource_code to -1 for future deletion

    UPDATE      CST_ITEM_CST_DTLS_INTERFACE CICDI
    SET
                operation_sequence_id   =   NULL,   --operation_sequence_id,
                operation_seq_num       =   NULL,   --operation_seq_num,
                department_id           =   NULL,   --department_id,
                activity_id             =   NULL,   --activity_id,
                resource_seq_num        =   NULL,   --resource_seq_num,
                resource_id             =   -1,     --resource_id,
                resource_rate           =   1,      -- resource_rate
                usage_rate_or_amount    =   CICDI.item_cost,
                                                    -- usage_rate_or_amount
                basis_type              =   1,      --basis_type, -- Always Item Based
                basis_resource_id       =   NULL,   --basis_resource_id,
                basis_factor            =   1,      --basis_factor, -- Always Item Based
                item_cost               =   CICDI.item_cost,
                                                    -- item cost
                rollup_source_type      =   1,      -- rollup_source_type = Always user-defined
                activity_context        =   NULL,   --activity_context,
                department              =   NULL,   -- department
                activity                =   NULL,   -- activity
                resource_code           =   '-1',   -- resource_code
                basis_resource_code     =   NULL    -- basis_resource_code

    WHERE       CICDI.group_id      = p_group_id
    AND         CICDI.activity = l_activity_code
    AND         nvl(CICDI.resource_code,'0') <> '-1';

  END LOOP;



 /* ********** Added for to_org is a Std Cost Org, have to handle NULL subelements ***** */

  SELECT	primary_cost_method
  INTO		l_primary_cost_method
  FROM		MTL_PARAMETERS MP
  WHERE		MP.organization_id = p_to_organization_id;

  IF (l_primary_cost_method = 1) THEN


  l_statement := 109;

    UPDATE      CST_ITEM_CST_DTLS_INTERFACE CICDI
    SET
                operation_sequence_id   =   NULL,   --operation_sequence_id,
                operation_seq_num       =   NULL,   --operation_seq_num,
                department_id           =   NULL,   --department_id,
                activity_id             =   NULL,   --activity_id,
                resource_seq_num        =   NULL,   --resource_seq_num,
                resource_id             =   -1,     --resource_id,
                resource_rate           =   1,      -- resource_rate
                usage_rate_or_amount    =   CICDI.item_cost,
                                                    -- usage_rate_or_amount
                basis_type              =   1,      --basis_type, -- Always Item Based
                basis_resource_id       =   NULL,   --basis_resource_id,
                basis_factor            =   1,      --basis_factor, -- Always Item Based
                item_cost               =   CICDI.item_cost,
                                                    -- item cost
                rollup_source_type      =   1,      -- rollup_source_type = Always user-defined
                activity_context        =   NULL,   --activity_context,
                department              =   NULL,   -- department
                activity                =   NULL,   -- activity
                resource_code           =   '-1',   -- resource_code
                basis_resource_code     =   NULL    -- basis_resource_code

    WHERE       CICDI.group_id      = p_group_id
    AND		CICDI.resource_id IS NULL
    AND		CICDI.resource_code IS NULL;

  END IF;


/* ***** End Additional logic for NULL subelements ******* */


 ELSIF (p_summary_option = 2) THEN

    l_statement := 110;

    -- Convert to Item Basis Type for all subelements
    -- Update the resource_id and resource_code to -1 for future deletion

    UPDATE      CST_ITEM_CST_DTLS_INTERFACE CICDI
    SET
                operation_sequence_id   =   NULL,   --operation_sequence_id,
                operation_seq_num       =   NULL,   --operation_seq_num,
                department_id           =   NULL,   --department_id,
                activity_id             =   NULL,   --activity_id,
                resource_seq_num        =   NULL,   --resource_seq_num,
                resource_id             =   -1,     --resource_id,
                resource_rate           =   1,      -- resource_rate
                usage_rate_or_amount    =   CICDI.item_cost,
                                                    -- usage_rate_or_amount
                basis_type              =   1,      --basis_type, -- Always Item Based
                basis_resource_id       =   NULL,   --basis_resource_id,
                basis_factor            =   1,      --basis_factor, -- Always Item Based
                item_cost               =   CICDI.item_cost,
                                                    -- item cost
                rollup_source_type      =   1,      -- rollup_source_type = Always user-defined
                activity_context        =   NULL,   --activity_context,
                department              =   NULL,   -- department
                activity                =   NULL,   -- activity
                resource_code           =   '-1',   -- resource_code
                basis_resource_code     =   NULL    -- basis_resource_code

    WHERE       CICDI.group_id      = p_group_id;


 END IF;

    l_statement := 115;

    -- Create summarized rows for every default subelement

    INSERT INTO CST_ITEM_CST_DTLS_INTERFACE
                (
                INVENTORY_ITEM_ID, --                        NUMBER
                COST_TYPE_ID, --                    NOT NULL NUMBER
                LAST_UPDATE_DATE, --                         DATE
                LAST_UPDATED_BY, --                          NUMBER
                CREATION_DATE, --                            DATE
                CREATED_BY, --                               NUMBER
                LAST_UPDATE_LOGIN, --                        NUMBER
                GROUP_ID, --                                 NUMBER
                ORGANIZATION_ID, --                          NUMBER
                OPERATION_SEQUENCE_ID, --                    NUMBER
                OPERATION_SEQ_NUM, --                        NUMBER
                DEPARTMENT_ID, --                            NUMBER
                LEVEL_TYPE, --                               NUMBER
                ACTIVITY_ID, --                              NUMBER
                RESOURCE_SEQ_NUM, --                         NUMBER
                RESOURCE_ID, --                              NUMBER
                RESOURCE_RATE, --                            NUMBER
                ITEM_UNITS, --                               NUMBER
                ACTIVITY_UNITS, --                           NUMBER
                USAGE_RATE_OR_AMOUNT, --                     NUMBER
                BASIS_TYPE, --                               NUMBER
                BASIS_RESOURCE_ID, --                        NUMBER
                BASIS_FACTOR, --                             NUMBER
                NET_YIELD_OR_SHRINKAGE_FACTOR, --            NUMBER
                ITEM_COST, --                                NUMBER
                COST_ELEMENT_ID, --                          NUMBER
                ROLLUP_SOURCE_TYPE, --                       NUMBER
                ACTIVITY_CONTEXT, --                         VARCHAR2(30)
                REQUEST_ID, --                               NUMBER
                ORGANIZATION_CODE, --                        VARCHAR2(3)
                COST_TYPE, --                                VARCHAR2(10)
                INVENTORY_ITEM, --                           VARCHAR2(240)
                DEPARTMENT, --                               VARCHAR2(10)
                ACTIVITY, --                                 VARCHAR2(10)
                RESOURCE_CODE, --                            VARCHAR2(10)
                BASIS_RESOURCE_CODE, --                      VARCHAR2(10)
                COST_ELEMENT, --                             VARCHAR2(50)
                ERROR_TYPE, --                               NUMBER
                PROGRAM_APPLICATION_ID , --                  NUMBER
                PROGRAM_ID, --                               NUMBER
                PROGRAM_UPDATE_DATE, --                      DATE
                ATTRIBUTE_CATEGORY, --                       VARCHAR2(30)
                ATTRIBUTE1, --                               VARCHAR2(150)
                ATTRIBUTE2, --                               VARCHAR2(150)
                ATTRIBUTE3, --                               VARCHAR2(150)
                ATTRIBUTE4, --                               VARCHAR2(150)
                ATTRIBUTE5, --                               VARCHAR2(150)
                ATTRIBUTE6, --                               VARCHAR2(150)
                ATTRIBUTE7, --                               VARCHAR2(150)
                ATTRIBUTE8, --                               VARCHAR2(150)
                ATTRIBUTE9, --                               VARCHAR2(150)
                ATTRIBUTE10, --                              VARCHAR2(150)
                ATTRIBUTE11, --                              VARCHAR2(150)
                ATTRIBUTE12, --                              VARCHAR2(150)
                ATTRIBUTE13, --                              VARCHAR2(150)
                ATTRIBUTE14, --                              VARCHAR2(150)
                ATTRIBUTE15, --                              VARCHAR2(150)
                TRANSACTION_ID, --                           NUMBER
                PROCESS_FLAG, --                             NUMBER
                ITEM_NUMBER, --                              VARCHAR2(81)
                TRANSACTION_TYPE, --                         VARCHAR2(10)
                YIELDED_COST --                             NUMBER
                )
        SELECT  CICDI2.INVENTORY_ITEM_ID,
                p_to_cost_type_id,          -- COST_TYPE_ID
                SYSDATE,                    -- LAST_UPDATE_DATE
                FND_GLOBAL.USER_ID,          -- LAST_UPDATED_BY
                SYSDATE,                    -- CREATION_DATE
                FND_GLOBAL.USER_ID,         -- CREATED_BY
                FND_GLOBAL.LOGIN_ID,        -- LAST_UPDATE_LOGIN
                p_group_id,                 -- GROUP_ID
                NULL,                       -- ORGANIZATION_ID
                NULL,                       -- OPERATION_SEQUENCE_ID
                NULL,                       -- OPERATION_SEQ_NUM,
                NULL,                       -- DEPARTMENT_ID,
                CICDI2.LEVEL_TYPE,          --
                NULL,                       -- ACTIVITY_ID
                NULL,                       -- RESOURCE_SEQ_NUM
                NULL,                       -- RESOURCE_ID
                1,                          -- RESOURCE_RATE
                NULL,                       -- ITEM_UNITS
                NULL,                       -- ACTIVITY_UNITS
                SUM(USAGE_RATE_OR_AMOUNT),
                1,                          -- BASIS_TYPE
                NULL,                       -- BASIS_RESOURCE_ID
                1,                          -- BASIS_FACTOR
                1,                          -- NET_YIELD_OR_SHRINKAGE_FACTOR
                SUM(ITEM_COST),
                CICDI2.COST_ELEMENT_ID,
                1,                          -- ROLLUP_SOURCE_TYPE
                NULL,                       -- ACTIVITY_CONTEXT
                FND_GLOBAL.CONC_REQUEST_ID, -- REQUEST_ID
                CICDI2.ORGANIZATION_CODE,
                CICDI2.COST_TYPE,
                CICDI2.INVENTORY_ITEM,
                NULL,			    -- DEPARTMENT
                NULL,                       -- ACTIVITY
                DECODE  (CICDI2.COST_ELEMENT_ID,
                            1, NVL(l_material_subelement_code,'-1'),
                            2, NVL(l_moh_subelement_code,'-1'),
                            3, NVL(l_resource_subelement_code,'-1'),
                            4, NVL(l_osp_subelement_code,'-1'),
                            5, NVL(l_overhead_subelement_code,'-1')),
                                            -- RESOURCE_CODE
                NULL,                       -- BASIS_RESOURCE_CODE
                CICDI2.COST_ELEMENT,
                NULL,                       -- ERROR_TYPE
                FND_GLOBAL.PROG_APPL_ID,    --PROGRAM_APPLICATION_ID
                FND_GLOBAL.CONC_PROGRAM_ID, -- PROGRAM_ID
                SYSDATE,                    -- PROGRAM_UPDATE_DATE
                NULL,                       -- ATTRIBUTE_CATEGORY
                NULL,                       -- ATTRIBUTE1
                NULL,                       -- ATTRIBUTE2
                NULL,                       -- ATTRIBUTE3
                NULL,                       -- ATTRIBUTE4
                NULL,                       -- ATTRIBUTE5
                NULL,                       -- ATTRIBUTE6
                NULL,                       -- ATTRIBUTE7
                NULL,                       -- ATTRIBUTE8
                NULL,                       -- ATTRIBUTE9
                NULL,                       -- ATTRIBUTE10
                NULL,                       -- ATTRIBUTE11
                NULL,                       -- ATTRIBUTE12
                NULL,                       -- ATTRIBUTE13
                NULL,                       -- ATTRIBUTE14
                NULL,                       -- ATTRIBUTE15
                NULL,                       -- TRANSACTION_ID
                NULL,                       -- PROCESS_FLAG
                NULL,                       -- ITEM_NUMBER
                NULL,                       -- TRANSACTION_TYPE
                SUM(CICDI2.YIELDED_COST)
        FROM    CST_ITEM_CST_DTLS_INTERFACE CICDI2
        WHERE   CICDI2.GROUP_ID   = p_group_id
        AND     CICDI2.RESOURCE_CODE = '-1'
        AND     CICDI2.RESOURCE_ID   = -1
        GROUP BY
                CICDI2.GROUP_ID,
                CICDI2.COST_ELEMENT,
                CICDI2.LEVEL_TYPE,
                CICDI2.ORGANIZATION_CODE,
                CICDI2.COST_TYPE,
                CICDI2.INVENTORY_ITEM,
                CICDI2.INVENTORY_ITEM_ID,
		CICDI2.COST_ELEMENT_ID;

        l_statement := 120;

        -- Delete all rows with resource_code and resourde_id = -1

        DELETE  CST_ITEM_CST_DTLS_INTERFACE CICDI
        WHERE   CICDI.RESOURCE_CODE = '-1'
        AND     CICDI.RESOURCE_ID   = -1
        AND     CICDI.GROUP_ID      = p_group_id;


	l_statement := 125;

/* ***** Rows generated bacause of missing default subelemnts ***** */

	SELECT	COUNT(*)
	INTO	l_miss_def_subelem
	FROM	CST_ITEM_CST_DTLS_INTERFACE CICDI
	WHERE   CICDI.RESOURCE_CODE = '-1'
        AND     CICDI.RESOURCE_ID  IS NULL
        AND     CICDI.GROUP_ID      = p_group_id;



	IF (l_miss_def_subelem > 0) THEN
            l_api_message := 'At Least One required Default Subelement is missing';
            FND_MESSAGE.set_name('BOM', 'CST_API_MESSAGE');
            FND_MESSAGE.set_token('TEXT', l_api_message);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error ;
        END IF;


 l_statement := 130;
 x_return_status := l_return_status;


 l_statement := 140;

 -- Standard check of p_commit
 IF FND_API.to_Boolean(p_commit) THEN
    COMMIT WORK;
 END IF;


 l_statement := 150;

 -- Standard Call to get message count and if count = 1, get message info
 FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );



 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
      --
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'CST_SubElements_PVT'
              , 'summarizeSubElements : Statement -'||to_char(l_statement)
              );

        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );
END summarizeSubElements;


END CST_SubElements_PVT;

/
