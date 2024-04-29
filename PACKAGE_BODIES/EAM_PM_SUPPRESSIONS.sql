--------------------------------------------------------
--  DDL for Package Body EAM_PM_SUPPRESSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PM_SUPPRESSIONS" AS
/* $Header: EAMPSUPB.pls 120.1 2005/05/30 10:34:56 appldev  $ */

  /**
   * This function is used to check whether a loop will be formed by adding a new
   * suppression relation as specified by the given parameters.
   * This should be called before the record is actually inserted into the table.
   */
  function check_no_loop(p_parent_assoc_id in number,
                         p_child_assoc_id  in number) return boolean is
    cursor C is
      select child_association_id
        from eam_suppression_relations
       where parent_association_id = p_child_assoc_id;

    x_child_id number;
  begin
    if ( p_child_assoc_id is null ) then
      return true;
    end if;

    if ( p_child_assoc_id = p_parent_assoc_id ) then
      return false;
    end if;

    -- go to child's children level to check
    open C;
    LOOP
      fetch C into x_child_id;
      EXIT WHEN ( C%NOTFOUND );
      if ( NOT check_no_loop(p_parent_assoc_id, x_child_id) ) then
        close C;
        return false;
      end if;
    END LOOP;
    close C;

    return true;
  end check_no_loop;


  /**
   * This procedure is used to check whether the suppression relationship rule is
   * broken or not by adding one more suppression relation. The rule is that one
   * can suppress many, but one can only be suppressed by one.
   * This should be called before the record is actually inserted into the table.
   */
  function is_supp_rule_maintained(p_parent_assoc_id in number,
                                   p_child_assoc_id  in number) return boolean is
    x_num number;
  begin
    select count(*) into x_num
      from eam_suppression_relations sup,
--           eam_pm_schedulings pms,
           mtl_eam_asset_activities eaa
     where sup.child_association_id = p_child_assoc_id
--       and sup.child_association_id = pms.activity_association_id
       and sup.child_association_id = eaa.activity_association_id
--       and nvl(pms.from_effective_date, sysdate-1) < sysdate
--       and nvl(pms.to_effective_date, sysdate+1) > sysdate
       and nvl(eaa.start_date_active, sysdate-1) < sysdate
       and nvl(eaa.end_date_active, sysdate+1) > sysdate;

    if ( x_num <> 0 ) then
      return false;
    else
      return true;
    end if;

  end is_supp_rule_maintained;

   PROCEDURE instantiate_suppressions(
	p_api_version           	IN	NUMBER				,
  	p_init_msg_list			IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status			OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,
	p_maintenance_object_id		IN 		NUMBER
)
IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'instantiate_suppressions';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;
	i				number;

    -- This cursor returns all suppression templates associated with the
    -- asset group
/*  	cursor asset_supp_csr is
    select  supp.parent_association_id, supp.child_association_id,
            msn.inventory_item_id
    from    mtl_serial_numbers msn, eam_suppression_relations supp,
            mtl_eam_asset_activities meaa
    where   msn.gen_object_id = p_maintenance_object_id and
            supp.tmpl_flag = 'Y' and
            meaa.tmpl_flag = 'Y' and
            supp.parent_association_id = meaa.activity_association_id and
            meaa.inventory_item_id = msn.inventory_item_id;  */

 cursor asset_supp_csr is
 select  supp.parent_association_id, supp.child_association_id,
            cii.inventory_item_id
    from    csi_item_instances cii, eam_suppression_relations supp,
            mtl_eam_asset_activities meaa
    where   cii.instance_id = p_maintenance_object_id and
            supp.tmpl_flag = 'Y' and
            meaa.tmpl_flag = 'Y' and
            supp.parent_association_id = meaa.activity_association_id and
            meaa.maintenance_object_id = cii.inventory_item_id
	    and meaa.maintenance_object_type=2;

BEGIN
   -- Standard Start of API savepoint
    SAVEPOINT	EAM_PM_SUPPRESSIONS;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body
	--dbms_output.put_line('instantiating meters');

	-- for loop that loops through each suppression
    for a_row in asset_supp_csr loop
	  instantiate_suppression(a_row.parent_association_id,
      a_row.child_association_id, p_maintenance_object_id);
	end loop;
	--dbms_output.put_line('end of for loop');
--	end if;

--	end loop;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		--dbms_output.put_line('g_exc_error');
		ROLLBACK TO EAM_PM_SUPPRESSIONS;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		--dbms_output.put_line('unexpected error');
		ROLLBACK TO instantiate_meters_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		--dbms_output.put_line('others');
		ROLLBACK TO EAM_PM_SUPPRESSIONS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);

END instantiate_suppressions;

procedure instantiate_suppression(
    p_parent_association_id IN NUMBER,
    p_child_association_id IN NUMBER,
    p_maintenance_object_id IN NUMBER) IS

    l_parent_assoc_id number;
    l_child_assoc_id number;
    cursor supp_cursor is
    select * from eam_suppression_relations
    where parent_association_id = p_parent_association_id
    and child_association_id = p_child_association_id;
    supp_rec supp_cursor%ROWTYPE;
BEGIN
    select meaa_an.activity_association_id into l_parent_assoc_id
    from mtl_eam_asset_activities meaa_an,
         mtl_eam_asset_activities meaa_ag
    where meaa_ag.activity_association_id = p_parent_association_id
    and meaa_ag.asset_activity_id = meaa_an.asset_activity_id
    and meaa_an.maintenance_object_id = p_maintenance_object_id;

    select meaa_an.activity_association_id into l_child_assoc_id
    from mtl_eam_asset_activities meaa_an,
         mtl_eam_asset_activities meaa_ag
    where meaa_ag.activity_association_id = p_child_association_id
    and meaa_ag.asset_activity_id = meaa_an.asset_activity_id
    and meaa_an.maintenance_object_id = p_maintenance_object_id;

    open supp_cursor;
    loop
      fetch supp_cursor into supp_rec;
      exit when supp_cursor%NOTFOUND;
      insert into eam_suppression_relations(
      parent_association_id,
      child_association_id,
      description,
	  tmpl_flag,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
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
      attribute15)
      values(
      l_parent_assoc_id,
      l_child_assoc_id,
      supp_rec.description,
  	  'N',
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
   	  fnd_global.login_id,
      supp_rec.attribute_category,
      supp_rec.attribute1,
      supp_rec.attribute2,
      supp_rec.attribute3,
      supp_rec.attribute4,
      supp_rec.attribute5,
      supp_rec.attribute6,
      supp_rec.attribute7,
      supp_rec.attribute8,
      supp_rec.attribute9,
      supp_rec.attribute10,
      supp_rec.attribute11,
      supp_rec.attribute12,
      supp_rec.attribute13,
      supp_rec.attribute14,
      supp_rec.attribute15 );
    end loop;
    close supp_cursor;

end instantiate_suppression;

END eam_pm_suppressions;


/
