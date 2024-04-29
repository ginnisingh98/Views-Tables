--------------------------------------------------------
--  DDL for Package Body HR_NL_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_ORG_INFO" AS
/* $Header: penlorgi.pkb 120.5 2007/03/12 15:19:30 summohan ship $ */
	g_package                  varchar2(33) := '  HR_NL_ORG_INFO.';
	--
	--
	--Cursor which fetches Organizations from the named hierarchy-bottom to top
	--
	CURSOR org_hierarchy(p_org_id NUMBER) IS
			SELECT p_org_id organization_id_parent
				   ,0 lev
			FROM dual
			UNION
			SELECT organization_id_parent
				   ,level
			FROM
			(SELECT organization_id_parent
					,organization_id_child
			  FROM per_org_structure_elements
		   WHERE org_structure_version_id = latest_named_hierarchy_vers(p_org_id)
			)
			START WITH organization_id_child    = p_org_id
			CONNECT BY PRIOR organization_id_parent   = organization_id_child
	ORDER BY lev;
	--
	--
	-- Service function to return the current named hioerarchy.
	--
	FUNCTION named_hierarchy
			 (p_organization_id NUMBER) RETURN NUMBER IS
	  --
	  --
	  -- Cursor to return the current named hierarchy.
	  --
	  CURSOR c_hierarchy(vp_organization_id NUMBER) IS
		SELECT TO_NUMBER(inf.org_information1) organization_structure_id
		FROM   hr_organization_information inf
			  ,hr_all_organization_units   org
		WHERE  org.organization_id         = vp_organization_id
		  AND  inf.organization_id         = org.business_group_id
		  AND  inf.org_information_context = 'NL_BG_INFO'
		  AND  inf.org_information1        IS NOT NULL;
	  --
	  --
	  -- Local Variables.
	  --
	  l_rec c_hierarchy%ROWTYPE;
	  l_proc varchar2(72) := g_package || '.named_hierarchy';
	BEGIN
	  --
	  --
	  -- Find the current named organization hierarchy.
	  --
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  OPEN  c_hierarchy(vp_organization_id => p_organization_id);
	  FETCH c_hierarchy INTO l_rec;
	  CLOSE c_hierarchy;
	  hr_utility.set_location('Leaving  ' || l_proc, 900);
	  --
	  --
	  -- Return ID.
	  --
	  RETURN l_rec.organization_structure_id;
	EXCEPTION
	  when others then
		hr_utility.set_location('Exception :' ||l_proc||SQLERRM(SQLCODE),999);
	END named_hierarchy;
	--
	--
	-- Service function to return the current version of the named hierarchy.
	--
	FUNCTION latest_named_hierarchy_vers
			(p_organization_id NUMBER) RETURN NUMBER IS
	  --
	  --
	  -- Cursor to return the current named hierarchy version.
	  --
	  CURSOR c_hierarchy_version(vp_organization_id NUMBER) IS
		SELECT sv.org_structure_version_id, sv.version_number
		FROM   per_org_structure_versions  sv
			  ,fnd_sessions                ses
		WHERE  sv.organization_structure_id = named_hierarchy(vp_organization_id)
		  AND  ses.session_id               = USERENV('sessionid')
		  AND  ses.effective_date BETWEEN sv.date_from
		  AND NVL(sv.date_to, Hr_general.End_Of_time)
		ORDER BY sv.version_number DESC;
	  --
	  --
	  -- Local Variables.
	  --
	  l_rec c_hierarchy_version%ROWTYPE;
	  l_proc varchar2(72) := g_package || '.latest_named_hierarchy_vers';
	BEGIN
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  --
	  --
	  -- Find the current primary organization hierarchy.
	  --
	  OPEN  c_hierarchy_version(vp_organization_id => p_organization_id);
	  FETCH c_hierarchy_version INTO l_rec;
	  CLOSE c_hierarchy_version;
	  hr_utility.set_location('Leaving  ' || l_proc, 900);
	  --
	  --
	  -- Return ID.
	  --
	  RETURN l_rec.org_structure_version_id;
	EXCEPTION
	  when others then
		hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);

	END latest_named_hierarchy_vers;
	--
	--
	-- Service function to see if organization belongs to the
	-- current named hierarchy.
	--
	FUNCTION org_exists_in_hierarchy
	(p_organization_id NUMBER) RETURN VARCHAR2 IS
	  --
	  --
	  -- Cursor to see if the organization belongs to the current
	  -- named hierarchy.
	  --
	  CURSOR c_org_exists(vp_organization_id NUMBER) IS
		SELECT se.organization_id_child
		FROM   per_org_structure_elements se
		WHERE  se.org_structure_version_id =
			   latest_named_hierarchy_vers(vp_organization_id)
		  AND  (se.organization_id_parent  = vp_organization_id OR
				se.organization_id_child   = vp_organization_id);
	  --
	  --
	  -- Local Variables.
	  --
	  l_rec c_org_exists%ROWTYPE;
	  l_proc varchar2(72) := g_package || '.org_exists_in_hierarchy';
	BEGIN
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  OPEN  c_org_exists(vp_organization_id => p_organization_id);
	  FETCH c_org_exists INTO l_rec;
	  IF c_org_exists%FOUND THEN
		CLOSE c_org_exists;
		hr_utility.set_location('Leaving ' || l_proc, 900);
		RETURN 'Y';
	  ELSE
		CLOSE c_org_exists;
		hr_utility.set_location('Leaving ' || l_proc, 910);
		RETURN 'N';
	  END IF;
	EXCEPTION
	  when others then
		hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
	END org_exists_in_hierarchy;

	/* -----------------------------------------------------------------------
	The procedure will return the value of the data item (Region and
	Organization Number) required. The org_id taken as input is the org_id for
	which the value is required.The procedure will navigate from the org_id
	supplied up the hierarchy until it finds a value for the data item.        |
	The following data items are required ;                                    |
	Data Item       Column            Table                        Context     |
	1. Region       org_information1  hr_organization_information  NL_ORG_INFO |
	2. Org. Number  org_information1  hr_organization_information  NL_ORG_INFO |
	---------------------------------------------------------------------------*/

	PROCEDURE get_org_data_items(
			p_org_id in number,
			p_region  out nocopy varchar2,
			p_organization_number out nocopy varchar2) IS
	 l_proc              varchar2(72) := g_package || '.get_org_data_items';
	 l_all_items_found   boolean := FALSE;
	 l_level             number;
	 l_organization_id   hr_organization_units.organization_id%type;
	 l_region     varchar2(255);
	 temp_region     varchar2(255);
	 l_organization_number     varchar2(255);
	 temp_organization_number     varchar2(255);
	 l_org_id                   hr_organization_units.organization_id%type;
	 l_org_information_context
	 hr_organization_information.org_information_context%type;
	/* Add a check to see if the data item has a value for the org_id supplied
	- add as a union or separate query */
	  CURSOR org_data_items
	  (l_org_id in hr_organization_units.organization_id%type) IS
	  select
			  substr(org_information1, 1, 30),
			  substr(org_information2, 1, 30)
	  from
	  hr_organization_units d,
	  hr_organization_information e
	  where
	  d.organization_id = e.organization_id and
	  d.organization_id = l_org_id and
	  e.org_information_context in ('NL_ORG_INFORMATION');
	BEGIN
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  temp_region := null;
	  temp_organization_number := null;
	  open org_hierarchy(p_org_id);
	  LOOP
		fetch org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_all_items_found =TRUE ;

		--Fetch Organization Information
		open org_data_items (l_organization_id);
		fetch org_data_items into l_region,l_organization_number;
		if org_data_items%found then
		  if l_region is not Null and temp_region is null then
			temp_region := l_region;
		  end if;
		  if l_organization_number is not Null
			 and temp_organization_number is Null then
				  temp_organization_number := l_organization_number;
		  end if;
		  if temp_region is not null and
				 temp_organization_number is not null then
				 l_all_items_found :=TRUE;
		  else
				 l_all_items_found :=FALSE ;
		  end if;
		end if;
		close org_data_items;

	 END LOOP;
	 close org_hierarchy;
	 p_region := temp_region;
	 p_organization_number := temp_organization_number;
	 hr_utility.set_location('Leaving  ' || l_proc, 900);


	EXCEPTION
	  when others then
		hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
		p_region := null;
		p_organization_number := null;
	END get_org_data_items;
	/*------------------------------------------------------------------------
	The following procedure checks if the Organization passed in exists in the
	Primary Hierarchy.
	--------------------------------------------------------------------------*/
	PROCEDURE chk_for_org_in_hierarchy
			  (p_org_id in hr_organization_units.organization_id%TYPE,
			   p_exists out nocopy varchar2) IS
	 l_organization_id hr_organization_units.organization_id%TYPE;
	 l_level           number;
	 l_proc            varchar2(72) := g_package || '.chk_for_org_in_hierarchy';
	BEGIN
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  p_exists := org_exists_in_hierarchy(p_org_id);
	  hr_utility.set_location('Leaving  ' || l_proc, 100);
	END chk_for_org_in_hierarchy;
	--
	--
	-- Function checks to see if organization belongs to the same region from
	-- the Org Hierarchy
	--
	FUNCTION Check_Org_In_Region
			(p_org_id in hr_organization_units.organization_id%TYPE,
			p_region in varchar2)
	RETURN hr_organization_units.organization_id%TYPE IS
	 l_organization_id      hr_organization_units.organization_id%TYPE;
	 l_level                number;

	 CURSOR cur_Region
	 (vp_Organization_ID in hr_organization_units.organization_id%TYPE,
	 vp_region in varchar2) IS
	 SELECT Organization_id,
	 org_information1 Region
	 FROM Hr_Organization_information
	 WHERE Organization_ID = vp_Organization_ID
	 AND Org_Information_Context='NL_ORG_INFORMATION';
	 v_cur_Region cur_Region%ROWTYPE;
	 --
	 --
	 -- Cursor which fetches Organizations from the named hierarchy
	 --
	 CURSOR org_named_hierarchy(vp_Organization_ID NUMBER) IS
	 SELECT vp_Organization_ID Organization_id,
			0 lev
	 FROM dual
	 UNION
	 SELECT organization_id_parent
	  ,level lev
	 FROM
	 (
	 SELECT organization_id_parent
	 ,organization_id_child
	 FROM per_org_structure_elements
	 WHERE org_structure_version_id =
	 hr_nl_org_info.latest_named_hierarchy_vers(vp_Organization_ID)
	 )
	 START WITH organization_id_child= vp_Organization_ID
	 CONNECT BY PRIOR organization_id_parent= organization_id_child
	 ORDER BY lev;
	 v_org_hierarchy org_named_hierarchy%ROWTYPE;
	 b_RegionInfoFound boolean := FALSE;
	 l_proc   varchar2(72) := g_package || '.Check_Org_In_Region';
	BEGIN
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  IF p_region is NOT NULL THEN
		 OPEN org_named_hierarchy(p_org_id);
		 LOOP
			hr_utility.set_location('Inside ' || l_proc, 105);
			FETCH org_named_hierarchy INTO v_org_hierarchy;
			EXIT WHEN org_named_hierarchy%NOTFOUND or b_RegionInfoFound=TRUE;
			OPEN cur_Region(v_org_hierarchy.organization_id,p_region);
			FETCH cur_Region INTO v_cur_Region;
			hr_utility.set_location('Inside ' || l_proc, 110);
			IF cur_Region%FOUND THEN
			  hr_utility.set_location('Inside ' || l_proc, 115);
			  IF v_cur_Region.Region IS NOT NULL AND
				v_cur_Region.Region=p_region THEN
				hr_utility.set_location('Inside ' || l_proc, 120);
				l_organization_id := p_org_id;
				b_RegionInfoFound := TRUE;
			  ELSIF v_cur_Region.Region IS NOT NULL AND
				v_cur_Region.Region<>p_region THEN
				hr_utility.set_location('Inside ' || l_proc, 125);
				l_organization_id := null;
				b_RegionInfoFound := TRUE;
			  END IF;
			END IF;
			CLOSE cur_Region;
		 END LOOP;
		 hr_utility.set_location('Inside ' || l_proc, 130);
		 CLOSE org_named_hierarchy;
	  END IF;
	  hr_utility.set_location('Leaving  ' || l_proc, 900);
	  return l_organization_id;
	EXCEPTION
	  when others then
		hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
	END Check_Org_In_Region;
	-- Service function which returns the SI Provider information for the given organization.
	-- It performs tree walk if SI information is not defined for the given organization.

	FUNCTION Get_SI_Org_Id
		(p_organization_id NUMBER,p_si_type VARCHAR2,p_assignment_id NUMBER) RETURN NUMBER IS
		l_proc  varchar2(72) := g_package || '.Get_SI_Org_Id';


		--
		-- Cursor which fetches Social Insurance Provider overridden at the Assignment Level
		-- ordering the records by the si class order (A record for a Individual SI type would be
		-- ordered higher than a AMI record).
		CURSOR asg_provider
		(l_org_id in hr_organization_units.organization_id%type,l_si_type varchar2,l_assgn_id NUMBER) IS
		 select pae.aei_information8 provider,
		 decode(pae.aei_information3,'AMI',0,1) si_class_order
		 from per_assignment_extra_info pae
		 ,fnd_sessions s
		 where assignment_id = l_assgn_id
		 and (pae.aei_information3=decode (l_si_type,'WEWE','WW','WEWA','WW',
						'WAOB','WAO','WAOD','WAO','PRIVATE_HEALTH','ZFW',l_si_type) or
		 pae.AEI_INFORMATION3 = DECODE(l_si_type,'WEWA','AMI','WEWE','AMI','WAOD','AMI','WAOB','AMI',
						'ZFW','AMI','PRIVATE_HEALTH','AMI','ZW','AMI',
						'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',l_si_type))
		and s.effective_date between
		fnd_date.canonical_to_date(pae.aei_information1)
		and nvl(fnd_date.canonical_to_date(pae.aei_information2),s.effective_date) AND
		s.session_id=userenv('sessionid')
		order by si_class_order desc;

		--
		-- Cursor which fetches Social Insurance Provider for the given Hr Organization
		-- and which offers si class ordering the records first by the Primary provider Flag
		-- and then by the si class order(A record for a Individual SI type would be
		-- ordered higher than a AMI record).
		CURSOR org_uwv_provider
		(l_org_id in hr_organization_units.organization_id%type,
		 l_uwv_id in hr_organization_units.organization_id%type,
		 l_si_type varchar2) IS
		 select
		 e.org_information_id,
		 e.org_information4 provider,nvl(e.org_information7,'N') p_flag,
		 decode(e.org_information3,'AMI',0,1) si_class_order
		 from
		 hr_organization_information e
		 ,fnd_sessions s
		 where
		 e.organization_id=l_org_id and
		 e.org_information_context = 'NL_SIP' and
		 (e.org_information3=DECODE(l_si_type,'WEWE','WW','WEWA','WW','WAOB','WAO','WAOD','WAO',
							 'PRIVATE_HEALTH','ZFW',l_si_type) or
		 e.org_information3 = DECODE(l_si_type,'WEWE','AMI','WEWA','AMI','WAOB','AMI','WAOD','AMI',
						'ZFW','AMI','PRIVATE_HEALTH','AMI','ZW','AMI',
						'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',l_si_type)) and
		 e.org_information4 = NVL(l_uwv_id,e.org_information4)
		 and s.effective_date between
		   fnd_date.canonical_to_date(e.org_INFORMATION1)
		   and nvl(fnd_date.canonical_to_date(e.org_INFORMATION2),s.effective_date) AND
		 s.session_id=userenv('sessionid')
		 order by p_flag desc,si_class_order desc;

		v_asg_provider      asg_provider%ROWTYPE;
		v_org_uwv_provider  org_uwv_provider%ROWTYPE;
		l_level             number;
		l_organization_id   hr_organization_units.organization_id%TYPE;
		l_org_found			boolean := false;
		l_uwv_org_id 		hr_organization_units.organization_id%TYPE;
		l_org_info_id 			hr_organization_units.organization_id%TYPE;
	 BEGIN
		/* Fetch Override Ins Provider at the Asg Level*/
		OPEN asg_provider(p_organization_id,p_si_type,p_assignment_id);
		FETCH asg_provider INTO v_asg_provider;
		CLOSE asg_provider;


		/* If Ins Provider at the Asg Level is specified*/
		IF v_asg_provider.provider IS NOT NULL THEN
		   l_uwv_org_id := v_asg_provider.provider;
		   hr_utility.set_location('Asg Level UWV Prov l_uwv_org_id'||l_uwv_org_id,100);
		END IF;

		/* If Ins Provider at the Asg Level is not specified
		tree walk to find the Primary Insurance Provider at the level */
		--hr_utility.set_location('Calling Get_SI_Org_Id',200);

		l_org_found := FALSE;
		l_org_info_id := -1;
		if org_hierarchy%ISOPEN then
			CLOSE org_hierarchy;
		END IF;
		/*Start looking for the UWV Provider beginning from the HR Org
		of Employee */

		OPEN org_hierarchy(p_organization_id);
		LOOP
			FETCH org_hierarchy into l_organization_id,l_level;
			exit when org_hierarchy%NOTFOUND or l_org_found =TRUE ;
			--hr_utility.set_location(' l_organization_id'||l_organization_id||' level '||l_level,300);
			--Fetch UWV Provider assigned to the HR Organization
			open org_uwv_provider(l_organization_id,l_uwv_org_id,p_si_type);
			FETCH org_uwv_provider into v_org_uwv_provider;
			if org_uwv_provider%found then
				--hr_utility.set_location(' l_organization_id'||l_organization_id||' p_organization_id '||p_organization_id,310);
				if l_organization_id =p_organization_id then
					/*Assign the UWV Provider defined at the HR Org
					But continue further to see if any Primary
					UWV exists up in the hierarchy*/
					l_org_info_id := v_org_uwv_provider.org_information_id;
					--hr_utility.set_location(' Assign -HR Org l_org_info_id'||l_org_info_id,320);
				else
					/*Assign the UWV Provider defined at the Parent HR Org if
					not overridden at the HR Org Level*/
					if l_org_info_id =-1 then
						l_org_info_id := v_org_uwv_provider.org_information_id;
						--hr_utility.set_location(' Parent HR Org l_org_info_id'||l_org_info_id,330);
					end if;
				end if;
				/*Check If the UWV Provider assigned is also the Primary
				 Quit Searching the hierarchy*/
				if v_org_uwv_provider.p_flag='Y' then
					l_org_found:=TRUE;
					l_org_info_id :=  v_org_uwv_provider.org_information_id;
					--hr_utility.set_location(' Primary UWV l_org_info_id'||l_org_info_id,340);
				end if;
			end if;
			close org_uwv_provider;
		END LOOP;
		close org_hierarchy;
		--hr_utility.set_location('Org Info Id :'||l_org_info_id||' UWV From Hierarchy l_uwv_org_id'||l_uwv_org_id,350);
		RETURN l_org_info_id;
	 EXCEPTION
		when others then
		--hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
		IF org_hierarchy%ISOPEN THEN
		  CLOSE org_hierarchy;
		END IF;
		RETURN -1;
	END Get_SI_Org_Id;


	-- Service function which returns the SI Provider information for the given organization.
	-- It performs tree walk if SI information is not defined for the given organization.
	--

	FUNCTION Get_SI_Provider_Info
		(p_organization_id NUMBER,p_si_type VARCHAR2,p_assignment_id NUMBER) RETURN NUMBER IS

		l_proc            varchar2(72) := g_package || '.Get_SI_Provider_Info';
		l_provider_info   hr_organization_units.organization_id%type;
		l_org_id          hr_organization_units.organization_id%type;


		--
		-- Cursor which fetches Social Insurance Provider overridden at the Assignment Level
		-- ordering the records by the si class order (A record for a Individual SI type would be
		-- ordered higher than a AMI record).
		CURSOR asg_provider
		(l_org_id in hr_organization_units.organization_id%type,l_si_type varchar2,l_assgn_id NUMBER) IS
		 select pae.aei_information8 provider,
		 decode(pae.aei_information3,'AMI',0,1) si_class_order
		 from per_assignment_extra_info pae
		 ,fnd_sessions s
		 where assignment_id = l_assgn_id
		 and (pae.aei_information3=decode (l_si_type,'WEWE','WW','WEWA','WW',
						'WAOB','WAO','WAOD','WAO','PRIVATE_HEALTH','ZFW',l_si_type) or
		 pae.aei_information3 = DECODE(l_si_type,'WEWE','AMI','WEWA','AMI',
						'WAOB','AMI','WAOD','AMI',
						'ZFW','AMI','PRIVATE_HEALTH','AMI','ZW','AMI',
						'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',l_si_type))
		and s.effective_date between
		fnd_date.canonical_to_date(pae.aei_information1)
		and nvl(fnd_date.canonical_to_date(pae.aei_information2),s.effective_date) AND
		s.session_id=userenv('sessionid')
		order by si_class_order desc;

		--
		-- Cursor which fetches Social Insurance Provider for the given Hr Organization
		-- and which offers SI type ordering the records first by the Primary provider Flag
		-- and then by the si class order(A record for a Individual SI type would be
		-- ordered higher than a AMI record).
		CURSOR org_uwv_provider
		(l_org_id in hr_organization_units.organization_id%type,l_si_type varchar2) IS
		 select
		 e.org_information4 provider,nvl(e.org_information7,'N') p_flag,
		 decode(e.org_information3,'AMI',0,1) si_class_order
		 from
		 hr_organization_information e
		 ,fnd_sessions s
		 where
		 e.organization_id=l_org_id and
		 e.org_information_context = 'NL_SIP' and
		 (e.org_information3=DECODE(l_si_type,'WEWE','WW','WEWA','WW','WAOB','WAO','WAOD','WAO',
							 'PRIVATE_HEALTH','ZFW',l_si_type) or
		 e.org_information3 = DECODE(l_si_type,'WEWE','AMI','WEWA','AMI','WAOB','AMI','WAOD','AMI',
						'ZFW','AMI','PRIVATE_HEALTH','AMI','ZW','AMI',
						'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',l_si_type)) and
		 s.effective_date between
		   fnd_date.canonical_to_date(e.org_INFORMATION1)
		   and nvl(fnd_date.canonical_to_date(e.org_INFORMATION2),s.effective_date) AND
		 s.session_id=userenv('sessionid')
		 order by p_flag desc,si_class_order desc;

		v_asg_provider      asg_provider%ROWTYPE;
		v_org_uwv_provider  org_uwv_provider%ROWTYPE;
		l_level             number;
		l_organization_id   hr_organization_units.organization_id%TYPE;
		l_uwv_found			boolean := false;
		l_uwv_org_id 		hr_organization_units.organization_id%TYPE;
	 BEGIN
		/* Fetch Override Ins Provider at the Asg Level*/
		OPEN asg_provider(p_organization_id,p_si_type,p_assignment_id);
		FETCH asg_provider INTO v_asg_provider;
		CLOSE asg_provider;


		/* If Ins Provider at the Asg Level is specified*/
		IF v_asg_provider.provider IS NOT NULL THEN
		   l_uwv_org_id := v_asg_provider.provider;
		   --hr_utility.set_location('Asg Level UWV Prov l_uwv_org_id'||l_uwv_org_id,100);
		ELSE
			/* If Ins Provider at the Asg Level is not specified
			tree walk to find the Primary Insurance Provider at the level */
			--hr_utility.set_location('Calling Get_SI_Org_Id',200);

			l_uwv_found := FALSE;
			l_uwv_org_id := -1;
			if org_hierarchy%ISOPEN then
				CLOSE org_hierarchy;
			END IF;
			/*Start looking for the UWV Provider beginning from the HR Org
			of Employee */

			OPEN org_hierarchy(p_organization_id);
			LOOP
				FETCH org_hierarchy into l_organization_id,l_level;
				exit when org_hierarchy%NOTFOUND or l_uwv_found =TRUE ;
				--hr_utility.set_location(' l_organization_id'||l_organization_id||' level '||l_level,300);
				--Fetch UWV Provider assigned to the HR Organization
				open org_uwv_provider(l_organization_id,p_si_type);
				FETCH org_uwv_provider into v_org_uwv_provider;
				if org_uwv_provider%found then
					--hr_utility.set_location(' l_organization_id'||l_organization_id||' p_organization_id '||p_organization_id,310);
					if l_organization_id =p_organization_id then
						/*Assign the UWV Provider defined at the HR Org
						But continue further to see if any Primary
						UWV exists up in the hierarchy*/
						l_uwv_org_id := v_org_uwv_provider.provider;
						--hr_utility.set_location(' Assign -HR Org l_uwv_org_id'||l_uwv_org_id,320);
					else
						/*Assign the UWV Provider defined at the Parent HR Org
						if not overridden at the HR Org Level*/
						if l_uwv_org_id =-1 then
							l_uwv_org_id := v_org_uwv_provider.provider;
							--hr_utility.set_location(' Parent HR Org l_uwv_org_id'||l_uwv_org_id,330);
						end if;
					end if;
					/*Check If the UWV Provider assigned is also the Primary
					 Quit Searching the hierarchy*/
					if v_org_uwv_provider.p_flag='Y' then
						l_uwv_found:=TRUE;
						l_uwv_org_id := v_org_uwv_provider.provider;
						--hr_utility.set_location(' Primary UWV l_uwv_org_id'||l_uwv_org_id||' @ '||l_organization_id,340);
					end if;

				end if;
				close org_uwv_provider;
			END LOOP;
			close org_hierarchy;
			--hr_utility.set_location(' UWV From Hierarchy l_uwv_org_id'||l_uwv_org_id,350);

		END IF;
		--hr_utility.set_location(' UWV ID -> l_uwv_org_id'||l_uwv_org_id,360);
		RETURN l_uwv_org_id;
	 EXCEPTION
		when others then
		hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
		IF org_hierarchy%ISOPEN THEN
		  CLOSE org_hierarchy;
		END IF;
		RETURN -1;
	 END Get_SI_Provider_Info;

	 --
	 -- Service function which returns the SI Provider information for the given assignment.
	 -- Its an Over Loaded Function ,fetches the Org Id and then calls the
	 -- other Over Loaded Function to Tree Walk and Fetch the provider info.
	 FUNCTION Get_SI_Provider_Info
		(p_assignment_id NUMBER,p_si_type VARCHAR2) RETURN NUMBER IS

		--Determine the Organization Id of the Employees Assignment
		CURSOR get_org_id(p_assignment_id number) is
		select paa.organization_id
		from per_all_assignments_f paa,fnd_sessions ses
		where paa.assignment_id = p_assignment_id and
		ses.effective_date between paa.effective_start_date and paa.effective_end_date and
		session_id = userenv('sessionid');

		l_org_id per_all_assignments_f.organization_id%TYPE;
		l_provider_id hr_organization_units.organization_id%TYPE;

	 BEGIN

		OPEN get_org_id(p_assignment_id);
		FETCH get_org_id into l_org_id;
		CLOSE get_org_id;

		l_provider_id:=Get_SI_Provider_Info(l_org_id,p_si_type,p_assignment_id);

		RETURN l_provider_id;

	 END Get_SI_Provider_Info;

	 --
	 --
	 -- Service function to see if uwv organization is assigned to
	 -- any hr organization in the hierarchy.
	 --
	 FUNCTION check_uwv_org_in_hierarchy
	   (p_uwv_org_id NUMBER,p_organization_id NUMBER) RETURN VARCHAR2 IS
		--
		--
		-- Cursor to see if the organization belongs to the current
		-- named hierarchy.
		--
		CURSOR org_uwv_provider
		(l_uwv_org_id in hr_organization_units.organization_id%type,
		l_org_id in hr_organization_units.organization_id%type) IS
		 select
		 e.org_information4 provider
		 from
		 hr_organization_information e
		 where
		 e.organization_id=l_org_id and
		 e.org_information_context = 'NL_SIP' and
		 e.org_information4 =l_uwv_org_id ;
		--
		--
		-- Local Variables.
		--
		l_uwv_found varchar2(1) := 'N';
		l_proc varchar2(72) := g_package || '.check_uwv_org_in_hierarchy';
		l_level             number;
		l_organization_id   hr_organization_units.organization_id%TYPE;
		v_org_uwv_provider  org_uwv_provider%ROWTYPE;
	 BEGIN
		l_uwv_found := 'N';
		IF org_hierarchy%ISOPEN THEN
			CLOSE org_hierarchy;
		END IF;
		/*Start looking for the UWV Provider beginning from the HR Org
		of Employee */

		OPEN org_hierarchy(p_organization_id);
		LOOP
			FETCH org_hierarchy into l_organization_id,l_level;
			exit when org_hierarchy%NOTFOUND or l_uwv_found ='Y' ;
			--hr_utility.set_location(' l_organization_id'||l_organization_id||' level '||l_level,300);
			--Fetch UWV Provider assigned to the HR Organization
			open org_uwv_provider(p_uwv_org_id,l_organization_id);
			FETCH org_uwv_provider into v_org_uwv_provider;
			IF org_uwv_provider%FOUND THEN
				l_uwv_found := 'Y';
			END IF;
			CLOSE org_uwv_provider;
		END LOOP;
		CLOSE org_hierarchy;
		RETURN l_uwv_found;
	 EXCEPTION
	   when others then
		hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
		IF org_hierarchy%ISOPEN THEN
			CLOSE org_hierarchy;
		END IF;
		RETURN l_uwv_found;
	 END check_uwv_org_in_hierarchy;
	--
	-- Service function to return the Info Id from the Assignment Extra Information
	-- to support AMI Enhancement
	-- Returns the ID for the Specified SI type defined,if not defined looks for a AMI
	-- record and returns it.
	FUNCTION Get_Asg_SII_Info_ID
	(p_assignment_id NUMBER,p_si_type VARCHAR2) RETURN NUMBER IS
		--
		-- Cursor which fetches Social Insurance Provider overridden at the Assignment Level
		-- ordering the records by the si class order (A record for a Individual SI type would be
		-- ordered higher than a AMI record).
		CURSOR asg_provider
		(l_assgn_id NUMBER,l_si_type varchar2) IS
		select pae.assignment_extra_info_id,
		decode(pae.aei_information3,'AMI',0,1) si_class_order
		from per_assignment_extra_info pae
		,fnd_sessions s
		where assignment_id = l_assgn_id
		and (pae.aei_information3=decode (l_si_type,'WEWE','WW','WEWA','WW',
					'WAOB','WAO','WAOD','WAO','PRIVATE_HEALTH','ZFW',l_si_type) or
		pae.AEI_INFORMATION3 = DECODE(l_si_type,'WEWA','AMI','WEWE','AMI','WAOD','AMI','WAOB','AMI',
					'ZFW','AMI','PRIVATE_HEALTH','AMI','ZW','AMI',
					'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',l_si_type))
		and s.effective_date between
		fnd_date.canonical_to_date(pae.aei_information1)
		and nvl(fnd_date.canonical_to_date(pae.aei_information2),s.effective_date)
		and session_id = userenv('sessionid')
		order by si_class_order desc;
		v_asg_provider      asg_provider%ROWTYPE;
	BEGIN
		OPEN asg_provider(p_assignment_id,p_si_type);
		FETCH asg_provider INTO v_asg_provider;
		CLOSE asg_provider;

		RETURN v_asg_provider.assignment_extra_info_id;
	END Get_Asg_SII_Info_ID;

	-- Function which returns average days per month for the given organization
	-- If the value is not specified for the given organization it performs the tree walk.

	FUNCTION Get_Avg_Days_Per_Month
	(p_assignment_id NUMBER) RETURN NUMBER IS
	--
	--Determine the Organization Id of the Employees Assignment
	--
	CURSOR get_org_id(p_assignment_id number) is
	select paa.organization_id
	from per_all_assignments_f paa,fnd_sessions ses
	where paa.assignment_id = p_assignment_id and
	ses.effective_date between paa.effective_start_date and paa.effective_end_date and
	session_id = userenv('sessionid');

	--
	--Cursor which fetches Tax Information for the given HR Organization
	--
	CURSOR Avg_Days_Per_Month
	(l_org_id in hr_organization_units.organization_id%type) IS
	 select
	 e.org_information_id,
	 e.org_information5 Avg_days_Per_Month
	 from
	 hr_organization_information e
	 where
	 e.organization_id=l_org_id and
	 e.org_information_context= 'NL_ORG_INFORMATION'
	 and e.org_information5 IS NOT NULL;
	--
	--Local Variables
	--
	l_avg_days	    Number;
	v_avg_days          Avg_Days_Per_Month%ROWTYPE;
	l_org_id            per_all_assignments_f.organization_id%TYPE;
	l_organization_id   hr_organization_units.organization_id%TYPE;
	l_level             number;

 BEGIN
	--
	--Determine the Organization Id of the Employees Assignment
	--
	OPEN get_org_id(p_assignment_id);
	FETCH get_org_id into l_org_id;
	CLOSE get_org_id;

	l_avg_days := Null;
	--
	--Check whether the Average Days Per Month is specified for the Organization
	--
	OPEN Avg_Days_Per_Month(l_org_id);
	Fetch Avg_Days_Per_Month into v_avg_days;
	If Avg_Days_Per_Month%FOUND and v_avg_days.Avg_days_Per_Month is not null then
	l_avg_days:= v_avg_days.Avg_days_Per_Month;
	End if;
	Close Avg_Days_Per_Month;

	--If the Average days per month is not specified tree walk to find the organization with
	--the same value defined.
	--
	IF l_avg_days IS NULL THEN

	if org_hierarchy%ISOPEN then
	CLOSE org_hierarchy;
	END IF;

	OPEN org_hierarchy(l_org_id);
	LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_avg_days IS NOT NULL;
		--
		--Fetch the avg days per month for the given organization
		--
		open Avg_Days_Per_Month(l_organization_id);
		FETCH Avg_Days_Per_Month into v_avg_days;
		if Avg_Days_Per_Month%found and v_avg_days.Avg_days_Per_Month is not null then
		l_avg_days:= v_avg_days.Avg_days_Per_Month;
		end if;
		close Avg_Days_Per_Month;
	END LOOP;
	close org_hierarchy;

	END IF;
	--If the value for average days per month is not specified anywhere up in the hierarchy default it to 30
	IF l_avg_days IS NULL THEN
	l_avg_days:=30;
	END IF;

	RETURN l_avg_days;
 EXCEPTION
	when others then
	--hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
	IF org_hierarchy%ISOPEN THEN
	  CLOSE org_hierarchy;
	END IF;
	RETURN 0;
 END Get_Avg_Days_Per_Month;
 	--
 	--Function which returns the tax organization for the given organization by traversing the org hierarchy
 	--
Function Get_Tax_Org_Id(p_org_structure_version_id NUMBER,p_organization_id NUMBER) RETURN NUMBER IS
	--
	-- Cursor which fetches Tax Information for the given HR Organization
	--
	CURSOR tax_organization
	(l_org_id in hr_organization_units.organization_id%type) IS
	 select
	 e.org_information_id,
	 e.org_information4 tax_information
	 from
	 hr_organization_information e
	 where
	 e.organization_id=l_org_id and
	 e.org_information_context= 'NL_ORG_INFORMATION'
	 and e.org_information3 IS NOT NULL
	 and e.org_information4 IS NOT NULL;


	--
	-- Cursor which fetches Tax Organization list for the given HR Organization
	--
	CURSOR tax_org_hierarchy(l_org_struct_version_id in per_org_structure_versions.org_structure_version_id%type,
	l_org_id in hr_organization_units.organization_id%type) IS
	SELECT tax_org_id,lev from hr_organization_information e,(
		SELECT l_org_id tax_org_id,0 lev from dual
		UNION
		SELECT distinct organization_id_parent
				   ,level
			FROM (
				SELECT distinct organization_id_parent, organization_id_child
				FROM per_org_structure_elements pose
				 where   pose.org_structure_version_id = l_org_struct_version_id)
		START WITH organization_id_child    = l_org_id
		CONNECT BY PRIOR organization_id_parent   = organization_id_child)
	where
	e.organization_id=tax_org_id and
	e.org_information_context= 'NL_ORG_INFORMATION'
	and e.org_information3 IS NOT NULL
	and e.org_information4 IS NOT NULL
	ORDER BY lev;

	v_tax_org           tax_organization%ROWTYPE;
	l_level             number;
	l_tax_org_id 	    hr_organization_units.organization_id%TYPE;

BEGIN
l_tax_org_id := NULL;

	OPEN tax_organization(p_organization_id);
	Fetch tax_organization into v_tax_org;
	If tax_organization%FOUND and v_tax_org.tax_information is not null then
	l_tax_org_id:= p_organization_id;
	End if;
	Close tax_organization;

	if tax_org_hierarchy%ISOPEN then
	CLOSE tax_org_hierarchy;
	end if;

	/*Fetch the tax organization list with tax information defined beginning from the HR Org */
	if l_tax_org_id IS NULL then
	OPEN tax_org_hierarchy(p_org_structure_version_id,p_organization_id);
	FETCH tax_org_hierarchy into l_tax_org_id,l_level;
	close tax_org_hierarchy;
	end if;

	RETURN l_tax_org_id;

EXCEPTION
when others then
	--hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
	IF tax_org_hierarchy%ISOPEN THEN
	  CLOSE tax_org_hierarchy;
	END IF;
RETURN null;
END Get_Tax_Org_Id;


        FUNCTION Get_Working_hours_Per_Week
        (p_org_id NUMBER) RETURN NUMBER IS
        --
        --Determine the Organization Id of the Employees Assignment
        --
        CURSOR get_org_id(p_assignment_id number) is
        select paa.organization_id
        from per_all_assignments_f paa,fnd_sessions ses
        where paa.assignment_id = p_assignment_id and
        ses.effective_date between paa.effective_start_date and paa.effective_end_date and
        session_id = userenv('sessionid');

        --
        --

        CURSOR Working_hours_Per_Week
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information7 working_hours
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information7 IS NOT NULL;
        --
        --Local Variables
        --
        l_working_hrs          Number;
        v_hrs_per_week      Working_hours_Per_Week%ROWTYPE;
        l_org_id            per_all_assignments_f.organization_id%TYPE;
        l_organization_id   hr_organization_units.organization_id%TYPE;
        l_level             number;

 BEGIN
        --
        --

        l_working_hrs:= Null;
        --
        --Check whether the Working_hours_Per_Week is specified for the Organization
        --
        OPEN Working_hours_Per_Week(p_org_id);
        Fetch Working_hours_Per_Week into v_hrs_per_week;
        If Working_hours_Per_Week%FOUND and v_hrs_per_week.working_hours is not null then
        l_working_hrs:= v_hrs_per_week.working_hours;
        End if;
        Close Working_hours_Per_Week;

       hr_utility.trace('l_working_hours is : '||l_working_hrs);

        --If the Working_hours_Per_Week is not specified tree walk to find the organization with
        --the same value defined.
        --
        IF l_working_hrs IS NULL THEN

        if org_hierarchy%ISOPEN then
        CLOSE org_hierarchy;
        END IF;

        OPEN org_hierarchy(p_org_id);
        LOOP
                FETCH org_hierarchy into l_organization_id,l_level;
                exit when org_hierarchy%NOTFOUND or l_working_hrs IS NOT NULL;
                --
                --
                OPEN Working_hours_Per_Week(l_organization_id);
                Fetch Working_hours_Per_Week into v_hrs_per_week;
		If Working_hours_Per_Week%FOUND and v_hrs_per_week.working_hours is not null then
                l_working_hrs:= v_hrs_per_week.working_hours;
                hr_utility.trace('l_working_hours from hierarchy is : '||l_working_hrs);
                end if;
                Close Working_hours_Per_Week;
        END LOOP;
        close org_hierarchy;

        END IF;


        RETURN l_working_hrs;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN 0;
 END Get_Working_hours_Per_Week;

-- Function which returns part time percentage method for the given organization
-- If the value is not specified for the given organization it performs the tree walk.

	FUNCTION Get_Part_Time_Perc_Method
	(p_assignment_id NUMBER) RETURN NUMBER IS
	--
	--Determine the Organization Id of the Employees Assignment
	--
	CURSOR get_org_id(p_assignment_id number) is
	select paa.organization_id
	from per_all_assignments_f paa,fnd_sessions ses
	where paa.assignment_id = p_assignment_id and
	ses.effective_date between paa.effective_start_date and paa.effective_end_date and
	session_id = userenv('sessionid');

	--
	--Cursor which fetches Part Time Percetage Method for the given HR Organization
	--
	CURSOR Part_Time_Percentage_Method
	(l_org_id in hr_organization_units.organization_id%type) IS
	 select
	 e.org_information_id,
	 e.org_information8 Part_Time_Percentage_Method
	 from
	 hr_organization_information e
	 where
	 e.organization_id=l_org_id and
	 e.org_information_context= 'NL_ORG_INFORMATION'
	 and e.org_information8 IS NOT NULL;
	--
	--Local Variables
	--
	l_part_time_per	    Number;
	v_part_time_per     Part_Time_Percentage_Method%ROWTYPE;
	l_org_id            per_all_assignments_f.organization_id%TYPE;
	l_organization_id   hr_organization_units.organization_id%TYPE;
	l_level             number;

 BEGIN
	--
	--Determine the Organization Id of the Employees Assignment
	--
	OPEN get_org_id(p_assignment_id);
	FETCH get_org_id into l_org_id;
	CLOSE get_org_id;

	l_part_time_per := Null;
	--
	--Check whether the Part Time Percetage Method is specified for the Organization
	--
	OPEN Part_Time_Percentage_Method(l_org_id);
	Fetch Part_Time_Percentage_Method into v_part_time_per;
	If Part_Time_Percentage_Method%FOUND and v_part_time_per.Part_Time_Percentage_Method is not null then
	l_part_time_per:= v_part_time_per.Part_Time_Percentage_Method;
	End if;
	Close Part_Time_Percentage_Method;

 	--If the Part Time Percetage Method is not specified tree walk to find the organization
	--with the same value defined.
	--
	IF l_part_time_per IS NULL THEN

	if org_hierarchy%ISOPEN then
	CLOSE org_hierarchy;
	END IF;

	OPEN org_hierarchy(l_org_id);
	LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_part_time_per IS NOT NULL;
		--
		--Fetch the Part Time Percetage Method for the given organization
		--
		open Part_Time_Percentage_Method(l_organization_id);
		FETCH Part_Time_Percentage_Method into v_part_time_per;
		if Part_Time_Percentage_Method%found and v_part_time_per.Part_Time_Percentage_Method is not null then
		l_part_time_per:= v_part_time_per.Part_Time_Percentage_Method;
		end if;
		close Part_Time_Percentage_Method;
	END LOOP;
	close org_hierarchy;

	END IF;
	IF l_part_time_per IS NULL THEN
l_part_time_per:=1;
END IF;

	RETURN l_part_time_per;
 EXCEPTION
	when others then
	--hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
	IF org_hierarchy%ISOPEN THEN
	  CLOSE org_hierarchy;
	END IF;
	RETURN 1;
 END Get_Part_Time_Perc_Method;

-- Function which returns lunar 5-week month wage method for the given organization
-- If the value is not specified for the given organization it performs the tree walk.

	FUNCTION Get_Lunar_5_Week_Method
	(p_assignment_id NUMBER) RETURN NUMBER IS
	--
	--Determine the Organization Id of the Employees Assignment
	--
	CURSOR get_org_id(p_assignment_id number) is
	select paa.organization_id
	from per_all_assignments_f paa,fnd_sessions ses
	where paa.assignment_id = p_assignment_id and
	ses.effective_date between paa.effective_start_date and paa.effective_end_date and
	session_id = userenv('sessionid');

	--
	--Cursor which fetches lunar 5 week month wage method for the given HR Organization
	--
	CURSOR Lunar_5_Week_Month_Wage_Method
	(l_org_id in hr_organization_units.organization_id%type) IS
	 select
	 e.org_information_id,
	 e.org_information9 Lunar_5_Week_Month_Wage_Method
	 from
	 hr_organization_information e
	 where
	 e.organization_id=l_org_id and
	 e.org_information_context= 'NL_ORG_INFORMATION'
	 and e.org_information9 IS NOT NULL;
	--
	--Local Variables
	--
	l_lunar_method	    Number;
	v_lunar_method	    Lunar_5_Week_Month_Wage_Method%ROWTYPE;
	l_org_id            per_all_assignments_f.organization_id%TYPE;
	l_organization_id   hr_organization_units.organization_id%TYPE;
	l_level             number;

 BEGIN
	--
	--Determine the Organization Id of the Employees Assignment
	--
	OPEN get_org_id(p_assignment_id);
	FETCH get_org_id into l_org_id;
	CLOSE get_org_id;

	l_lunar_method := Null;
	--
	--Check whether the lunar 5-week month wage method is specified for the Organization
	--
	OPEN Lunar_5_Week_Month_Wage_Method(l_org_id);
	Fetch Lunar_5_Week_Month_Wage_Method into v_lunar_method;
	If Lunar_5_Week_Month_Wage_Method%FOUND and v_lunar_method.Lunar_5_Week_Month_Wage_Method is not null then
	l_lunar_method:= v_lunar_method.Lunar_5_Week_Month_Wage_Method;
	End if;
	Close Lunar_5_Week_Month_Wage_Method;

	--If the lunar 5 week month wage method is not specified tree walk to find the organization with
	--the same value defined.
	--
	IF l_lunar_method IS NULL THEN

	if org_hierarchy%ISOPEN then
	CLOSE org_hierarchy;
	END IF;

	OPEN org_hierarchy(l_org_id);
	LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_lunar_method IS NOT NULL;
		--
		--Fetch the Part Time Percetage Method for the given organization
		--
		open Lunar_5_Week_Month_Wage_Method(l_organization_id);
		FETCH Lunar_5_Week_Month_Wage_Method into v_lunar_method;
		if Lunar_5_Week_Month_Wage_Method%found and v_lunar_method.Lunar_5_Week_Month_Wage_Method is not null then
		l_lunar_method:= v_lunar_method.Lunar_5_Week_Month_Wage_Method;
		end if;
		close Lunar_5_Week_Month_Wage_Method;
	END LOOP;
	close org_hierarchy;

	END IF;
	IF l_lunar_method IS NULL THEN
	l_lunar_method:=0;
	END IF;
	RETURN l_lunar_method;
 EXCEPTION
	when others then
	--hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
	IF org_hierarchy%ISOPEN THEN
	  CLOSE org_hierarchy;
	END IF;
	RETURN 0;
 END Get_Lunar_5_Week_Method;

 -- Start NL_Proration

 FUNCTION Get_Proration_Tax_Table
        (p_assignment_id number) RETURN Varchar2 IS
        --
        --Determine the Organization Id of the Employees Assignment
        --
        CURSOR get_org_id(p_assignment_id number) is
        select paa.organization_id
        from per_all_assignments_f paa,fnd_sessions ses
        where paa.assignment_id = p_assignment_id and
        ses.effective_date between paa.effective_start_date
        and paa.effective_end_date and
        session_id = userenv('sessionid');

        --
        --

        CURSOR cur_Pro_Tax_Table
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information10 Proration_Tax_Table
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information10 IS NOT NULL;
        --
        --Local Variables
        --
        l_Pro_Tax_Table         hr_organization_information.ORG_INFORMATION10%TYPE;
	v_Pro_Tax_Table         cur_Pro_Tax_Table%ROWTYPE;
        l_org_id	        per_all_assignments_f.organization_id%TYPE;
        l_organization_id       hr_organization_units.organization_id%TYPE;
        l_level                 number;

 BEGIN
        --
        --
	 --
	 --Determine the Organization Id of the Employees Assignment
	 --
	 OPEN get_org_id(p_assignment_id);
	 FETCH get_org_id into l_org_id;
	 CLOSE get_org_id;

        l_Pro_Tax_Table:= Null;
        --
        --Check whether the Period_type is specified for the Organization
        --
        OPEN cur_Pro_Tax_Table (l_org_id);
        Fetch cur_Pro_Tax_Table into v_Pro_Tax_Table;
        If cur_Pro_Tax_Table%FOUND and
           v_Pro_Tax_Table.Proration_Tax_Table is not null then
        l_Pro_Tax_Table:= v_Pro_Tax_Table.Proration_Tax_Table;
        End if;
        Close cur_Pro_Tax_Table;

        hr_utility.trace('l_Pro_Tax_Table is : '||l_Pro_Tax_Table);

        --If the Working_hours_Per_Week is not specified tree walk
        --to find the organization with
        --the same value defined.
        --
        IF l_Pro_Tax_Table IS NULL THEN

        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;

        OPEN org_hierarchy(l_org_id);
        LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_Pro_Tax_Table IS NOT NULL;
		--
		--
		OPEN Cur_Pro_Tax_Table(l_organization_id);
		Fetch Cur_Pro_Tax_Table into v_Pro_Tax_Table;
		If Cur_Pro_Tax_Table%FOUND and
          v_Pro_Tax_Table.Proration_Tax_Table is not null then
			l_Pro_Tax_Table:= v_Pro_Tax_Table.Proration_Tax_Table;
		end if;
		Close Cur_Pro_Tax_Table;
        END LOOP;
        close org_hierarchy;

        END IF;
	--If the value for Proration Tax Table is not specified anywhere
       --up in the hierarchy default it to 1
	IF l_Pro_Tax_Table IS NULL THEN
		l_Pro_Tax_Table :=1;
	END IF;

        RETURN l_Pro_Tax_Table;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN '0';
 END Get_Proration_Tax_Table;


 -- End NL_Proration

	-- Service function which returns the SI Provider information for the given organization.
	-- It performs tree walk if SI information is not defined for the given organization.
	--

	FUNCTION Get_ER_SI_Prov_HR_Org_ID
	(p_organization_id NUMBER,p_si_type VARCHAR2,p_assignment_id NUMBER) RETURN NUMBER IS

		l_proc            varchar2(72) := g_package || '.Get_SI_Provider_Info';
		l_provider_info   hr_organization_units.organization_id%type;
		l_org_id          hr_organization_units.organization_id%type;


		--
		-- Cursor which fetches Social Insurance Provider overridden at the Assignment Level
		-- ordering the records by the si class order (A record for a Individual SI type would be
		-- ordered higher than a AMI record).
		CURSOR asg_provider
		(l_org_id in hr_organization_units.organization_id%type,l_si_type varchar2,l_assgn_id NUMBER) IS
		 select pae.aei_information8 provider,
		 decode(pae.aei_information3,'AMI',0,1) si_class_order
		 from per_assignment_extra_info pae
		 ,fnd_sessions s
		 where assignment_id = l_assgn_id
		 and (pae.aei_information3=decode (l_si_type,'WEWE','WW','WEWA','WW',
						'WAOB','WAO','WAOD','WAO','PRIVATE_HEALTH','ZFW',l_si_type) or
		 pae.aei_information3 = DECODE(l_si_type,'WEWE','AMI','WEWA','AMI',
						'WAOB','AMI','WAOD','AMI',
						'ZFW','AMI','PRIVATE_HEALTH','AMI','ZW','AMI',
						'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',l_si_type))
		and s.effective_date between
		fnd_date.canonical_to_date(pae.aei_information1)
		and nvl(fnd_date.canonical_to_date(pae.aei_information2),s.effective_date) AND
		s.session_id=userenv('sessionid')
		order by si_class_order desc;

		--
		-- Cursor which fetches Social Insurance Provider for the given Hr Organization
		-- and which offers SI type ordering the records first by the Primary provider Flag
		-- and then by the si class order(A record for a Individual SI type would be
		-- ordered higher than a AMI record).
		CURSOR org_uwv_provider
		(l_org_id in hr_organization_units.organization_id%type,l_si_type varchar2) IS
		 select
		 e.org_information4 provider,nvl(e.org_information7,'N') p_flag,
		 decode(e.org_information3,'AMI',0,1) si_class_order
		 from
		 hr_organization_information e
		 ,fnd_sessions s
		 where
		 e.organization_id=l_org_id and
		 e.org_information_context = 'NL_SIP' and
		 (e.org_information3=DECODE(l_si_type,'WEWE','WW','WEWA','WW','WAOB','WAO','WAOD','WAO',
							 'PRIVATE_HEALTH','ZFW',l_si_type) or
		 e.org_information3 = DECODE(l_si_type,'WEWE','AMI','WEWA','AMI','WAOB','AMI','WAOD','AMI',
						'ZFW','AMI','PRIVATE_HEALTH','AMI','ZW','AMI',
						'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',l_si_type)) and
		 s.effective_date between
		   fnd_date.canonical_to_date(e.org_INFORMATION1)
		   and nvl(fnd_date.canonical_to_date(e.org_INFORMATION2),s.effective_date) AND
		 s.session_id=userenv('sessionid')
		 order by p_flag desc,si_class_order desc;

		v_asg_provider      asg_provider%ROWTYPE;
		v_org_uwv_provider  org_uwv_provider%ROWTYPE;
		l_level             number;
		l_organization_id   hr_organization_units.organization_id%TYPE;
		l_uwv_found			boolean := false;
		l_uwv_org_id 		hr_organization_units.organization_id%TYPE;
		l_er_org_id 		hr_organization_units.organization_id%TYPE;
	 BEGIN
		/* Fetch Override Ins Provider at the Asg Level*/
		OPEN asg_provider(p_organization_id,p_si_type,p_assignment_id);
		FETCH asg_provider INTO v_asg_provider;
		CLOSE asg_provider;


		/* If Ins Provider at the Asg Level is specified*/
		IF v_asg_provider.provider IS NOT NULL THEN
		   l_uwv_org_id := v_asg_provider.provider;
		   l_er_org_id  := p_organization_id;
		   --hr_utility.set_location('Asg Level UWV Prov l_uwv_org_id'||l_uwv_org_id,100);
		ELSE
			/* If Ins Provider at the Asg Level is not specified
			tree walk to find the Primary Insurance Provider at the level */
			--hr_utility.set_location('Calling Get_SI_Org_Id',200);

			l_uwv_found := FALSE;
			l_uwv_org_id := -1;
			l_er_org_id := -1;
			if org_hierarchy%ISOPEN then
				CLOSE org_hierarchy;
			END IF;
			/*Start looking for the UWV Provider beginning from the HR Org
			of Employee */

			OPEN org_hierarchy(p_organization_id);
			LOOP
				FETCH org_hierarchy into l_organization_id,l_level;
				exit when org_hierarchy%NOTFOUND or l_uwv_found =TRUE ;
				--hr_utility.set_location(' l_organization_id'||l_organization_id||' level '||l_level,300);
				--Fetch UWV Provider assigned to the HR Organization
				open org_uwv_provider(l_organization_id,p_si_type);
				FETCH org_uwv_provider into v_org_uwv_provider;
				if org_uwv_provider%found then
					--hr_utility.set_location(' l_organization_id'||l_organization_id||' p_organization_id '||p_organization_id,310);
					if l_organization_id =p_organization_id then
						/*Assign the UWV Provider defined at the HR Org
						But continue further to see if any Primary
						UWV exists up in the hierarchy*/
						l_uwv_org_id := v_org_uwv_provider.provider;
						l_er_org_id  := l_organization_id;
						--hr_utility.set_location(' Assign -HR Org l_uwv_org_id'||l_uwv_org_id,320);
					else
						/*Assign the UWV Provider defined at the Parent HR Org
						if not overridden at the HR Org Level*/
						if l_uwv_org_id =-1 then
							l_uwv_org_id := v_org_uwv_provider.provider;
							l_er_org_id  := l_organization_id;
							--hr_utility.set_location(' Parent HR Org l_uwv_org_id'||l_uwv_org_id,330);
						end if;
					end if;
					/*Check If the UWV Provider assigned is also the Primary
					 Quit Searching the hierarchy*/
					if v_org_uwv_provider.p_flag='Y' then
						l_uwv_found:=TRUE;
						l_uwv_org_id := v_org_uwv_provider.provider;
						l_er_org_id  := l_organization_id;
						--hr_utility.set_location(' Primary UWV l_uwv_org_id'||l_uwv_org_id||' @ '||l_organization_id,340);
					end if;

				end if;
				close org_uwv_provider;
			END LOOP;
			close org_hierarchy;
			--hr_utility.set_location(' UWV From Hierarchy l_uwv_org_id'||l_uwv_org_id,350);

		END IF;
		hr_utility.set_location(' UWV ID -> l_uwv_org_id'||l_uwv_org_id,360);
		hr_utility.set_location('ER UWV ID -> l_er_org_id'||l_er_org_id,360);
		RETURN l_er_org_id;
	 EXCEPTION
		when others then
		hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
		IF org_hierarchy%ISOPEN THEN
		  CLOSE org_hierarchy;
		END IF;
		RETURN -1;
	 END Get_ER_SI_Prov_HR_Org_ID;


-- To get all the employers for given Org Struct Version ID
function Get_Employers_List(p_Org_Struct_Version_Id in number,
                            p_top_org_id in number,
                            p_sub_emp in varchar2)
return varchar2 is

	cursor c_all_emp is
	select pose.organization_id_child employer
	from per_org_structure_elements pose,hr_organization_information e
	where pose.org_structure_version_id = P_Org_Struct_Version_Id
	and e.organization_id=pose.organization_id_child
	and ((e.org_information_context= 'NL_ORG_INFORMATION'
	and e.org_information3 IS NOT NULL
	and e.org_information4 IS NOT NULL)
	or (e.org_information_context= 'NL_LE_TAX_DETAILS'
	and e.org_information1 IS NOT NULL
	and e.org_information2 IS NOT NULL))
	start with pose.organization_id_parent = p_top_org_id
	connect by prior pose.organization_id_child = pose.organization_id_parent
	union
	select to_number(p_top_org_id) employer from dual;

	emp_list varchar2(1000);

begin
	if ((P_SUB_EMP='N') or (P_SUB_EMP is null)) then
		emp_list := p_top_org_id;
	else
	for i in c_all_emp
	loop
		if emp_list is not null then
			emp_list:=emp_list||','||i.employer;
		else
			emp_list:=i.employer;
		end if;
	end loop;
	END if;
	return '('||emp_list||')';

end Get_Employers_List;

-- Function which returns parental leave wage percentage for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Parental_Leave_Wage_Perc(p_assignment_id NUMBER) RETURN NUMBER IS
	--
	--Determine the Organization Id of the Employees Assignment
	--
	CURSOR get_org_id(p_assignment_id number) is
	select paa.organization_id
	from per_all_assignments_f paa,fnd_sessions ses
	where paa.assignment_id = p_assignment_id and
	ses.effective_date between paa.effective_start_date and paa.effective_end_date and
	session_id = userenv('sessionid');

	--
	--Cursor which fetches Tax Information for the given HR Organization
	--
	CURSOR csr_Parental_Leave_Perc
	(l_org_id in hr_organization_units.organization_id%type) IS
	 select
	 e.org_information_id,
	 e.org_information11 Parental_Leave_Perc
	 from
	 hr_organization_information e
	 where
	 e.organization_id=l_org_id and
	 e.org_information_context= 'NL_ORG_INFORMATION'
	 and e.org_information11 IS NOT NULL;
	--
	--Local Variables
	--
	l_parental_leave_perc	    Number;
	v_csr_par_leave             csr_Parental_Leave_Perc%ROWTYPE;
	l_org_id                    per_all_assignments_f.organization_id%TYPE;
	l_organization_id           hr_organization_units.organization_id%TYPE;
	l_level                     number;

 BEGIN
	--
	--Determine the Organization Id of the Employees Assignment
	--
	OPEN get_org_id(p_assignment_id);
	FETCH get_org_id into l_org_id;
	CLOSE get_org_id;

	l_parental_leave_perc := Null;
	--
	--Check whether the Paid Parental Leave Percentage is specified for the Organization
	--
	OPEN csr_Parental_Leave_Perc(l_org_id);
	Fetch csr_Parental_Leave_Perc into v_csr_par_leave;
	If csr_Parental_Leave_Perc%FOUND and v_csr_par_leave.Parental_Leave_Perc is not null then
		l_parental_leave_perc:= v_csr_par_leave.Parental_Leave_Perc;
	End if;
	Close csr_Parental_Leave_Perc;

	--If the Paid Parental Leave Percentage is not specified tree walk to find
	--the organization with the  value defined.
	--
	IF l_parental_leave_perc IS NULL THEN

		if org_hierarchy%ISOPEN then
			CLOSE org_hierarchy;
		END IF;

		OPEN org_hierarchy(l_org_id);
		LOOP
			FETCH org_hierarchy into l_organization_id,l_level;
			exit when org_hierarchy%NOTFOUND or l_parental_leave_perc IS NOT NULL;
			--
			--Fetch the Parental Leave Percentage for the given organization
			--
			open csr_Parental_Leave_Perc(l_organization_id);
			FETCH csr_Parental_Leave_Perc into v_csr_par_leave;
			if csr_Parental_Leave_Perc%found and v_csr_par_leave.Parental_Leave_Perc is not null then
				l_parental_leave_perc:= v_csr_par_leave.Parental_Leave_Perc;
			end if;
			close csr_Parental_Leave_Perc;
		END LOOP;
		close org_hierarchy;

	END IF;
	--If the value for Parental Leave Percentage is not specified anywhere up in the hierarchy default it to 0
	IF l_parental_leave_perc IS NULL THEN
		l_parental_leave_perc:=0;
	END IF;

	RETURN l_parental_leave_perc;
 EXCEPTION
	when others then
	--hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
	IF org_hierarchy%ISOPEN THEN
	  CLOSE org_hierarchy;
	END IF;
	RETURN 0;

END Get_Parental_Leave_Wage_Perc;

-- Start CBS Reporting Frequency
FUNCTION Get_Reporting_Frequency
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2 IS
        CURSOR csr_cbs_rep_freq
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information15 cbs_reporting_frequency
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information15 IS NOT NULL;
        --
        --Local Variables
        --
        l_cbs_Rep_Freq          hr_organization_information.ORG_INFORMATION15%TYPE;
	   v_Rep_Freq_Table           csr_cbs_rep_freq%ROWTYPE;
        l_org_id	            per_all_assignments_f.organization_id%TYPE;
        l_organization_id       hr_organization_units.organization_id%TYPE;
        l_level                 number;
 BEGIN
        --
        --
         l_cbs_Rep_Freq  := Null;
        --
        --Check whether the Reporting_Frequency is specified for the Organization
        --
        OPEN csr_cbs_rep_freq (p_org_id);
        Fetch csr_cbs_rep_freq into v_Rep_Freq_Table ;
        If csr_cbs_rep_freq %FOUND and
           v_Rep_Freq_Table.cbs_reporting_frequency is not null then
        l_cbs_Rep_Freq:= v_Rep_Freq_Table.cbs_reporting_frequency;
        End if;
        Close csr_cbs_rep_freq;
        hr_utility.trace('l_cbs_Rep_Freq is : '||l_cbs_Rep_Freq);
        --If the Working_hours_Per_Week is not specified tree walk
        --to find the organization with
        --the same value defined.
        --
        IF l_cbs_Rep_Freq IS NULL THEN
        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;
        OPEN org_hierarchy(p_org_id);
        LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_cbs_Rep_Freq IS NOT NULL;
		--
		--
		OPEN csr_cbs_rep_freq(l_organization_id);
		Fetch csr_cbs_rep_freq into v_Rep_Freq_Table;
		If csr_cbs_rep_freq%FOUND and
          v_Rep_Freq_Table.cbs_reporting_frequency is not null then
			l_cbs_Rep_Freq:= v_Rep_Freq_Table.cbs_reporting_frequency;
		end if;
		Close csr_cbs_rep_freq;
        END LOOP;
        close org_hierarchy;
        END IF;
	--If the value for Proration Tax Table is not specified anywhere
       --up in the hierarchy default it to 1
	IF l_cbs_Rep_Freq IS NULL THEN
		l_cbs_Rep_Freq :=1;
	END IF;
        RETURN l_cbs_Rep_Freq;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN '0';
 END Get_Reporting_Frequency;
 --
 --
 -- Start Customer Number
 --
FUNCTION Get_customer_number
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2 IS
        CURSOR csr_customer_number
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information16 cbs_cust_number
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information16 IS NOT NULL;
        --
        --Local Variables
        --
        l_cbs_cust_num          hr_organization_information.ORG_INFORMATION16%TYPE;
	v_cust_num_table        csr_customer_number%ROWTYPE;
        l_org_id	        per_all_assignments_f.organization_id%TYPE;
        l_organization_id       hr_organization_units.organization_id%TYPE;
        l_level                 number;
 BEGIN
        --
        --
         l_cbs_cust_num  := Null;
        --
        --Check whether the Reporting_Frequency is specified for the Organization
        --
        OPEN csr_customer_number (p_org_id);
        Fetch csr_customer_number into v_cust_num_table ;
        If csr_customer_number %FOUND and
           v_cust_num_table.cbs_cust_number is not null then
        l_cbs_cust_num:= v_cust_num_table.cbs_cust_number;
        End if;
        Close csr_customer_number;
        hr_utility.trace('l_cbs_cust_num is : '||l_cbs_cust_num);
        --If the Working_hours_Per_Week is not specified tree walk
        --to find the organization with
        --the same value defined.
        --
        IF l_cbs_cust_num IS NULL THEN
        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;
        OPEN org_hierarchy(p_org_id);
        LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_cbs_cust_num IS NOT NULL;
		--
		--
		OPEN csr_customer_number(l_organization_id);
		Fetch csr_customer_number into v_cust_num_table;
		If csr_customer_number%FOUND and
          v_cust_num_table.cbs_cust_number is not null then
			l_cbs_cust_num:= v_cust_num_table.cbs_cust_number;
		end if;
		Close csr_customer_number;
        END LOOP;
        close org_hierarchy;
        END IF;
        RETURN l_cbs_cust_num;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN 'Error';
 END Get_customer_number;
--
-- Start Company Unit
--
FUNCTION Get_company_unit
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2 IS
        CURSOR csr_company_unit
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information18 cbs_company_unit
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information18 IS NOT NULL;
        --
        --Local Variables
        --
        l_cbs_company_unit         hr_organization_information.ORG_INFORMATION18%TYPE;
	v_company_unit_table        csr_company_unit%ROWTYPE;
        l_org_id	        per_all_assignments_f.organization_id%TYPE;
        l_organization_id       hr_organization_units.organization_id%TYPE;
        l_level                 number;
 BEGIN
        --
        --
         l_cbs_company_unit  := Null;
        --
        --Check whether the Reporting_Frequency is specified for the Organization
        --
        OPEN csr_company_unit (p_org_id);
        Fetch csr_company_unit into v_company_unit_table ;
        If csr_company_unit %FOUND and
           v_company_unit_table.cbs_company_unit is not null then
        l_cbs_company_unit:= v_company_unit_table.cbs_company_unit;
        End if;
        Close csr_company_unit;
        hr_utility.trace('l_cbs_company_unit is : '||l_cbs_company_unit);
        --If the Working_hours_Per_Week is not specified tree walk
        --to find the organization with
        --the same value defined.
        --
        IF l_cbs_company_unit IS NULL THEN
        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;
        OPEN org_hierarchy(p_org_id);
        LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_cbs_company_unit IS NOT NULL;
		--
		--
		OPEN csr_company_unit(l_organization_id);
		Fetch csr_company_unit into v_company_unit_table;
		If csr_company_unit%FOUND and
          v_company_unit_table.cbs_company_unit is not null then
			l_cbs_company_unit:= v_company_unit_table.cbs_company_unit;
		end if;
		Close csr_company_unit;
        END LOOP;
        close org_hierarchy;
        END IF;
	--If the value for Company Unit is not specified anywhere
       --up in the hierarchy default it to 0
	IF l_cbs_company_unit IS NULL THEN
		l_cbs_company_unit := 0;
	END IF;
        RETURN l_cbs_company_unit;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN '0';
 END Get_company_unit;
--
-- Start Get_Public_Sector_Org
FUNCTION Get_Public_Sector_Org
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2 IS
        CURSOR csr_public_sector_info
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information17 cbs_public_sector_org
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information17 IS NOT NULL;
        --
        --Local Variables
        --
        l_cbs_public_sector         hr_organization_information.ORG_INFORMATION17%TYPE;
	v_public_sector_Table       csr_public_sector_info%ROWTYPE;
        l_org_id	            per_all_assignments_f.organization_id%TYPE;
        l_organization_id           hr_organization_units.organization_id%TYPE;
        l_level                     number;
 BEGIN
        --
        --
         l_cbs_public_sector  := Null;
        --
        --Check whether the Public_Sector Information is specified for the Organization
        --
        OPEN csr_public_sector_info (p_org_id);
        Fetch csr_public_sector_info into v_public_sector_Table ;
        If csr_public_sector_info %FOUND and
           v_public_sector_Table.cbs_public_sector_org is not null then
        l_cbs_public_sector:= v_public_sector_Table.cbs_public_sector_org;
        End if;
        Close csr_public_sector_info;
        hr_utility.trace('l_cbs_Rep_Freq is : '||l_cbs_public_sector);

        --
        IF l_cbs_public_sector IS NULL THEN
        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;
        OPEN org_hierarchy(p_org_id);
        LOOP
			FETCH org_hierarchy into l_organization_id,l_level;
			exit when org_hierarchy%NOTFOUND or l_cbs_public_sector IS NOT NULL;
			--
			--
			OPEN csr_public_sector_info(l_organization_id);
			Fetch csr_public_sector_info into v_public_sector_Table;
			If csr_public_sector_info%FOUND and
			  v_public_sector_Table.cbs_public_sector_org is not null then
				l_cbs_public_sector:= v_public_sector_Table.cbs_public_sector_org;
			end if;
			Close csr_public_sector_info;
        END LOOP;
        close org_hierarchy;
        END IF;
	--If the value for Proration Tax Table is not specified anywhere
       --up in the hierarchy default it to 1
	IF l_cbs_public_sector IS NULL THEN
		l_cbs_public_sector :=1;
	END IF;
        RETURN l_cbs_public_sector;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN '0';
 END Get_Public_Sector_Org;

-- Function which returns Full Sickness Wage Paid Indicator for the given organization
-- If the value is not specified for the given organization it performs the tree walk.
FUNCTION Get_Full_Sickness_Wage_Paid
        (p_org_id in hr_organization_units.organization_id%type) RETURN Varchar2 IS
        CURSOR csr_full_wage_paid
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information19 full_sick_wage_paid
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information19 IS NOT NULL;
        --
        --Local Variables
        --
        l_full_wage_paid         hr_organization_information.ORG_INFORMATION17%TYPE;
		v_full_sick_wage       csr_full_wage_paid%ROWTYPE;
        l_org_id	            per_all_assignments_f.organization_id%TYPE;
        l_organization_id           hr_organization_units.organization_id%TYPE;
        l_level                     number;
 BEGIN
        --
        --
         l_full_wage_paid  := Null;
        --
        --Check whether the Full Sickness Wage Paid Indicator is specified for the Organization
        --
        OPEN csr_full_wage_paid (p_org_id);
        Fetch csr_full_wage_paid into v_full_sick_wage ;
        If csr_full_wage_paid %FOUND and
           v_full_sick_wage.full_sick_wage_paid is not null then
        l_full_wage_paid:= v_full_sick_wage.full_sick_wage_paid;
        End if;
        Close csr_full_wage_paid;
        hr_utility.trace('l_cbs_Rep_Freq is : '||l_full_wage_paid);

        --
        IF l_full_wage_paid IS NULL THEN
        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;
        OPEN org_hierarchy(p_org_id);
        LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_full_wage_paid IS NOT NULL;
		--
		--
		OPEN csr_full_wage_paid(l_organization_id);
		Fetch csr_full_wage_paid into v_full_sick_wage;
		If csr_full_wage_paid%FOUND and
          v_full_sick_wage.full_sick_wage_paid is not null then
			l_full_wage_paid:= v_full_sick_wage.full_sick_wage_paid;
		end if;
		Close csr_full_wage_paid;
        END LOOP;
        close org_hierarchy;
        END IF;

		RETURN l_full_wage_paid;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN '0';
 END Get_Full_Sickness_Wage_Paid;

 --
FUNCTION Get_IZA_Weekly_Full_Hours
        (p_assignment_id in NUMBER ) RETURN Varchar2 IS
    -- Determine the Organization Id of the Employees Assignment
	--
	CURSOR get_org_id(p_assignment_id number) is
	select paa.organization_id
	from per_all_assignments_f paa,fnd_sessions ses
	where paa.assignment_id = p_assignment_id and
	ses.effective_date between paa.effective_start_date and paa.effective_end_date and
	session_id = userenv('sessionid');
        CURSOR csr_IZA_Weekly_Hours
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information20 IZA_Weekly_Hours
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information20 IS NOT NULL;
        --
        --Local Variables
        --
        l_IZA_Weekly_Hours         hr_organization_information.ORG_INFORMATION20%TYPE;
	    v_IZA_Weekly_Hours_table        csr_IZA_Weekly_Hours%ROWTYPE;
        l_org_id	            per_all_assignments_f.organization_id%TYPE;
        l_organization_id       hr_organization_units.organization_id%TYPE;
        l_level                 number;
 BEGIN
        --
         --Determine the Organization Id of the Employees Assignment
	--
	OPEN get_org_id(p_assignment_id);
	FETCH get_org_id into l_org_id;
	CLOSE get_org_id;
        --
         l_IZA_Weekly_Hours  := Null;
        --
        --Check whether the IZA_Weekly_Hours is specified for the Organization
        --
        OPEN csr_IZA_Weekly_Hours (l_org_id);
        Fetch csr_IZA_Weekly_Hours into v_IZA_Weekly_Hours_table ;
        If csr_IZA_Weekly_Hours %FOUND and
           v_IZA_Weekly_Hours_table.IZA_Weekly_Hours is not null then
        l_IZA_Weekly_Hours:= v_IZA_Weekly_Hours_table.IZA_Weekly_Hours;
        End if;
        Close csr_IZA_Weekly_Hours;
        hr_utility.trace('l_IZA_Weekly_Hours is : '||l_IZA_Weekly_Hours);
        --If the IZA_Weekly_Hours is not specified tree walk
        --to find the organization with
        --the same value defined.
        --
        IF l_IZA_Weekly_Hours IS NULL THEN
        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;
        OPEN org_hierarchy(l_org_id);
        LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_IZA_Weekly_Hours IS NOT NULL;
		--
		--
		OPEN csr_IZA_Weekly_Hours(l_organization_id);
		Fetch csr_IZA_Weekly_Hours into v_IZA_Weekly_Hours_table;
		If csr_IZA_Weekly_Hours %FOUND and
          v_IZA_Weekly_Hours_table.IZA_Weekly_Hours is not null then
			l_IZA_Weekly_Hours:= v_IZA_Weekly_Hours_table.IZA_Weekly_Hours;
		end if;
		Close csr_IZA_Weekly_Hours;
        END LOOP;
        close org_hierarchy;
        END IF;
	-- If the value for IZA_Weely_Hours is not specified anywhere
    -- up in the hierarchy default it to 36
	IF l_IZA_Weekly_Hours IS NULL THEN
		l_IZA_Weekly_Hours := 36;
	END IF;
        RETURN l_IZA_Weekly_Hours;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN '0';
 END Get_IZA_Weekly_Full_Hours;

-- Start Monthly Full time Hours
FUNCTION Get_IZA_Monthly_Full_Hours
 (p_assignment_id in NUMBER ) RETURN Varchar2 IS
    -- Determine the Organization Id of the Employees Assignment
	--
	CURSOR get_org_id(p_assignment_id number) is
	select paa.organization_id
	from per_all_assignments_f paa,fnd_sessions ses
	where paa.assignment_id = p_assignment_id and
	ses.effective_date between paa.effective_start_date and paa.effective_end_date and
	session_id = userenv('sessionid');
	--
        CURSOR csr_IZA_Monthly_Hours
        (l_org_id in hr_organization_units.organization_id%type) IS
         select
         e.org_information_id,
         e.org_information12 IZA_Monthly_Hours
         from
         hr_organization_information e
         where
         e.organization_id=l_org_id and
         e.org_information_context= 'NL_ORG_INFORMATION'
         and e.org_information12 IS NOT NULL;
        --
        --Local Variables
        --
        l_IZA_Monthly_Hours         hr_organization_information.ORG_INFORMATION12%TYPE;
	    v_IZA_Monthly_Hours_table        csr_IZA_Monthly_Hours%ROWTYPE;
        l_org_id	            per_all_assignments_f.organization_id%TYPE;
        l_organization_id       hr_organization_units.organization_id%TYPE;
        l_level                 number;
 BEGIN
        --
        --Determine the Organization Id of the Employees Assignment
	--
	OPEN get_org_id(p_assignment_id);
	FETCH get_org_id into l_org_id;
	CLOSE get_org_id;
        --
         l_IZA_Monthly_Hours  := Null;
        --
        --Check whether the IZA_Monthly_Hours is specified for the Organization
        --
        OPEN csr_IZA_Monthly_Hours (l_org_id);
        Fetch csr_IZA_Monthly_Hours into v_IZA_Monthly_Hours_table ;
        If csr_IZA_Monthly_Hours %FOUND and
           v_IZA_Monthly_Hours_table.IZA_Monthly_Hours is not null then
        l_IZA_Monthly_Hours:= v_IZA_Monthly_Hours_table.IZA_Monthly_Hours;
        End if;
        Close csr_IZA_Monthly_Hours;
        hr_utility.trace('l_IZA_Monthly_Hours is : '||l_IZA_Monthly_Hours);
        --If the IZA_Monthly_Hours is not specified tree walk
        --to find the organization with
        --the same value defined.
        --
        IF l_IZA_Monthly_Hours IS NULL THEN
        if org_hierarchy%ISOPEN then
        	CLOSE org_hierarchy;
        END IF;
        OPEN org_hierarchy(l_org_id);
        LOOP
		FETCH org_hierarchy into l_organization_id,l_level;
		exit when org_hierarchy%NOTFOUND or l_IZA_Monthly_Hours IS NOT NULL;
		--
		--
		OPEN csr_IZA_Monthly_Hours(l_organization_id);
		Fetch csr_IZA_Monthly_Hours into v_IZA_Monthly_Hours_table;
		If csr_IZA_Monthly_Hours %FOUND and
          v_IZA_Monthly_Hours_table.IZA_Monthly_Hours is not null then
			l_IZA_Monthly_Hours:= v_IZA_Monthly_Hours_table.IZA_Monthly_Hours;
		end if;
		Close csr_IZA_Monthly_Hours;
        END LOOP;
        close org_hierarchy;
        END IF;
	-- If the value for IZA_Weely_Hours is not specified anywhere
    -- up in the hierarchy default it to 36
	IF l_IZA_Monthly_Hours IS NULL THEN
		l_IZA_Monthly_Hours := 156;
	END IF;
        RETURN l_IZA_Monthly_Hours;
 EXCEPTION
        when others then
        --hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
        IF org_hierarchy%ISOPEN THEN
          CLOSE org_hierarchy;
        END IF;
        RETURN '0';
 END Get_IZA_Monthly_Full_Hours;


 Function Get_IZA_Org_Id(p_org_structure_version_id NUMBER,p_organization_id NUMBER) RETURN NUMBER IS
 	--
 	-- Cursor which fetches IZA Information for the given HR Organization
 	--
 	CURSOR iza_organization
 	(l_org_id in hr_organization_units.organization_id%type) IS
 	 select
 	 e.org_information_id,
 	 e.org_information1 iza_information
 	 from
 	 hr_organization_information e
 	 where
 	 e.organization_id=l_org_id and
 	 e.org_information_context= 'NL_IZA_REPO_INFO'
 	 and e.org_information1 IS NOT NULL
 	 and e.org_information2 IS NOT NULL;


 	--
 	-- Cursor which fetches IZA Organization list for the given HR Organization
 	--
 	CURSOR iza_org_hierarchy(l_org_struct_version_id in per_org_structure_versions.org_structure_version_id%type,
 	l_org_id in hr_organization_units.organization_id%type) IS
 	SELECT iza_org_id,lev from hr_organization_information e,(
 		SELECT l_org_id iza_org_id,0 lev from dual
 		UNION
 		SELECT distinct organization_id_parent
 				   ,level
 			FROM per_org_structure_elements pose
 			 where   pose.org_structure_version_id = l_org_struct_version_id
 		START WITH organization_id_child    = l_org_id
 		CONNECT BY PRIOR organization_id_parent   = organization_id_child)
 	where
 	e.organization_id=iza_org_id and
 	e.org_information_context= 'NL_IZA_REPO_INFO'
 	and e.org_information1 IS NOT NULL
 	and e.org_information2 IS NOT NULL
 	ORDER BY lev;

 	v_iza_org           iza_organization%ROWTYPE;
 	l_level             number;
 	l_iza_org_id 	    hr_organization_units.organization_id%TYPE;

 BEGIN
 l_iza_org_id := NULL;

 	OPEN iza_organization(p_organization_id);
 	Fetch iza_organization into v_iza_org;
 	If iza_organization%FOUND and v_iza_org.iza_information is not null then
 	l_iza_org_id:= p_organization_id;
 	End if;
 	Close iza_organization;

 	if iza_org_hierarchy%ISOPEN then
 	CLOSE iza_org_hierarchy;
 	end if;

 	/*Fetch the iza organization list with iza information defined beginning from the HR Org */
 	if l_iza_org_id IS NULL then
 	OPEN iza_org_hierarchy(p_org_structure_version_id,p_organization_id);
 	FETCH iza_org_hierarchy into l_iza_org_id,l_level;
 	close iza_org_hierarchy;
 	end if;

 	RETURN l_iza_org_id;

 EXCEPTION
 when others then
 	--hr_utility.set_location('Exception :' || l_proc||SQLERRM(SQLCODE),999);
 	IF iza_org_hierarchy%ISOPEN THEN
 	  CLOSE iza_org_hierarchy;
 	END IF;
 RETURN null;
 END Get_IZA_Org_Id;




END HR_NL_ORG_INFO;

/
