--------------------------------------------------------
--  DDL for Package Body BEN_COPY_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COPY_EXTRACT" AS
/* $Header: bexcpapi.pkb 120.5 2006/03/21 19:03:40 tjesumic noship $ */

-- Type Declaration

TYPE IdTyp is RECORD (
 		     curr_Id	NUMBER(15)
 		    ,new_Id	NUMBER(15)
 		    );

TYPE ExtId IS TABLE OF IdTyp;

-- Package Variables
--
t_Formulas	ben_copy_extract.FormulaID;
t_DinRId	ExtId;
t_RinFId	ExtId;

g_package  	VARCHAR2(33) := '  BEN_COPY_EXTRACT.';

g_truncated	BOOLEAN; -- Has an entity name been truncated while prefixing?

g_msg_app       varchar2(30) ; 		-- bug 2459050

--Package constants

/* If the max length value of any of the following constants or any
   new constants is more than 200(c_ExtName_Maxlen), please also make
   the following change in the declaration section of the function
   FIX_NAME_LENGTH :
   	l_new_name VARCHAR2(<max length value of all the constants below>);

   e.g.: As currently the maximum length value is 200, the declaration should be
      		l_new_name	VARCHAR2(200);
*/
c_FFName_Maxlen		CONSTANT NUMBER := 80; -- Max length of FF Names
c_UDTName_Maxlen	CONSTANT NUMBER := 80; -- Max length of UDT Names
-- Changed max length of extract entity names for UTF8
c_ExtName_Maxlen	CONSTANT NUMBER := 600; -- Max length of Extract Entity Names


-- ----------------------------------------------------------------------------
-- |------------------------< ADD_FORMULA_ID  >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_formula_id(p_formula_id IN NUMBER) IS
  l_proc 	VARCHAR2(72) := g_package||'add_formula_id';
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  IF t_Formulas IS NULL THEN
      t_Formulas(1) := p_formula_id;
  ELSE
      t_Formulas(t_Formulas.COUNT+1) := p_formula_id;
  END IF;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
END; -- add_formula_id

-- ----------------------------------------------------------------------------
-- |------------------------< ADD_DinR_ID  >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_DinR_id(p_curr_DinR_id IN NUMBER
		     ,p_new_DinR_id  IN NUMBER) IS

  l_proc 	VARCHAR2(72) := g_package||'add_DinR_id';
  r_DinR	IdTyp;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Assign values into record variable
  r_DinR.curr_Id := p_curr_DinR_id;
  r_DinR.new_Id  := p_new_DinR_id;

  IF t_DinRId IS NULL THEN
      t_DinRId := ExtId(r_DinR);
  ELSE
      t_DinRId.EXTEND;
      t_DinRId(t_DinRId.COUNT) := r_DinR;
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
END; -- add_DinR_id

-- ----------------------------------------------------------------------------
-- |------------------------< add_RinF_Id  >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_RinF_id(p_curr_RinF_id IN NUMBER
		     ,p_new_RinF_id  IN NUMBER) IS

  l_proc 	VARCHAR2(72) := g_package||'add_RinF_Id';
  r_RinF	IdTyp;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Assign values into record variable
  r_RinF.curr_Id := p_curr_RinF_id;
  r_RinF.new_Id  := p_new_RinF_id;

  IF t_RinFId IS NULL THEN
      t_RinFId := ExtId(r_RinF);
  ELSE
      t_RinFId.EXTEND;
      t_RinFId(t_RinFId.COUNT) := r_RinF;
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
END; -- add_DinR_id

-- ----------------------------------------------------------------------------
-- |------------------------< GET_NEW_DATA_ELMT_ID >--------------------------|
-- ----------------------------------------------------------------------------
FUNCTION fix_name_length(p_curr_name	IN VARCHAR2
			,p_name_maxlen	IN NUMBER
			) RETURN VARCHAR2 IS

  l_new_name	ben_Ext_data_elmt.name%type ;

BEGIN

  if length(nvl(p_curr_name,0)) > p_name_maxlen then
    l_new_name := substr(p_curr_name,1,p_name_maxlen);
    g_truncated := TRUE;
  else
    l_new_name := p_curr_name;
  end if;

  RETURN l_new_name;

END; -- fix_name_length

-- ----------------------------------------------------------------------------
-- |------------------------< GET_MSG_NAME  >---------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_msg_name RETURN VARCHAR2 IS

  l_encoded_msg		VARCHAR2(3000);
  l_msg_name		VARCHAR2(30);
  l_msg_app		VARCHAR2(50);
  l_proc 		VARCHAR2(72) := g_package||'get_msg_name';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_encoded_msg := fnd_message.get_encoded();
  fnd_message.parse_encoded(
                	    encoded_message => l_encoded_msg
                	   ,app_short_name  => l_msg_app -- OUT
                	   ,message_name	=> l_msg_name -- OUT
                	   );

  g_msg_app := l_msg_app ;  -- bug 2459050

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_msg_name;

END; -- get_msg_name

-- ----------------------------------------------------------------------------
-- |------------------------< GET_NEW_DATA_ELMT_ID >--------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_new_data_elmt_id(p_curr_data_elmt_id	IN NUMBER
			     ,p_new_extract_name	IN VARCHAR2
                             ,p_business_group_id       IN NUMBER
			     ) RETURN NUMBER IS

  CURSOR c_new_data_elmt_id IS
  SELECT ext_data_elmt_id
  FROM ben_ext_data_elmt
  WHERE (p_business_group_id is null
        or p_business_group_id = business_group_id )
  and name = (SELECT fix_name_length(p_new_extract_name||' '||name
  				      ,c_ExtName_Maxlen)
  		FROM ben_ext_data_elmt
  		WHERE ext_data_elmt_id = p_curr_data_elmt_id);

  l_new_data_elmt_id	NUMBER(15) := NULL;
  l_proc 		VARCHAR2(72) := g_package||'get_new_data_elmt_id';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN c_new_data_elmt_id;
  FETCH c_new_data_elmt_id into l_new_data_elmt_id;
  CLOSE c_new_data_elmt_id;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_new_data_elmt_id;

END; -- get_new_data_elmt_id

-- ----------------------------------------------------------------------------
-- |------------------------< GET_NEW_WCDINR_DATA_ELMT_IN_RCD_ID >------------|
-- ----------------------------------------------------------------------------
FUNCTION get_new_WCDInR_DInR_id(p_curr_cond_DinR_id	IN NUMBER
				    ,p_new_ext_rcd_id		IN NUMBER
				    ,p_new_extract_name		IN VARCHAR2
                                    ,p_business_group_id         in number
				    ) RETURN NUMBER IS
  CURSOR c_new_data_elmt_in_rcd_id IS
  SELECT ext_data_elmt_in_rcd_id
  FROM ben_ext_data_elmt_in_rcd
  WHERE ext_rcd_id = p_new_ext_rcd_id
    AND ext_data_elmt_id = (SELECT ext_data_elmt_id
                            FROM ben_ext_data_elmt
                            WHERE  (p_business_group_id is null or
                                   p_business_group_id = business_group_id  )
                                  and  name =
                                   (SELECT fix_name_length(p_new_extract_name||' '||De.name
                                   			  ,c_ExtName_Maxlen)
                                    FROM ben_ext_data_elmt De
                                        ,ben_ext_data_elmt_in_rcd DinR
                                    WHERE DinR.ext_data_elmt_in_rcd_id = p_curr_cond_DinR_id
                                      AND DinR.ext_data_elmt_id = De.ext_data_elmt_id
                                   )
                           );

l_new_data_elmt_in_rcd_id	NUMBER(15) := NULL;
l_proc 				VARCHAR2(72) := g_package||'get_new_WCDInR_DInR_id';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN c_new_data_elmt_in_rcd_id;
  FETCH c_new_data_elmt_in_rcd_id INTO l_new_data_elmt_in_rcd_id;
  CLOSE c_new_data_elmt_in_rcd_id;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_new_data_elmt_in_rcd_id;


END; -- get_new_WCDInR_DInR_id

-- ----------------------------------------------------------------------------
-- |------------------------< get_new_WCRInF_DInR_id >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_new_WCRInF_DInR_id(p_curr_cond_DinR_id	IN NUMBER
			       ,p_new_rcd_in_file_id	IN NUMBER
			       ,p_new_extract_name	IN VARCHAR2
			       ) RETURN NUMBER IS

  CURSOR c_new_data_elmt_in_rcd_id IS
  SELECT ext_data_elmt_in_rcd_id
  FROM ben_ext_data_elmt_in_rcd
  WHERE ext_rcd_id = (SELECT ext_rcd_id
  		      FROM ben_ext_rcd_in_file
  		      WHERE ext_rcd_in_file_id = p_new_rcd_in_file_id
  		     )
    AND ext_data_elmt_id = (SELECT ext_data_elmt_id
                            FROM ben_ext_data_elmt
                            WHERE name =
                                   (SELECT fix_name_length(p_new_extract_name||' '||De.name
                                   			  ,c_ExtName_Maxlen)
                                    FROM ben_ext_data_elmt De
                                        ,ben_ext_data_elmt_in_rcd DinR
                                    WHERE DinR.ext_data_elmt_in_rcd_id = p_curr_cond_DinR_id
                                      AND DinR.ext_data_elmt_id = De.ext_data_elmt_id
                                   )
                           );

l_new_data_elmt_in_rcd_id	NUMBER(15) := NULL;
l_proc 				VARCHAR2(72) := g_package||'get_new_WCRInF_DInR_id';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN c_new_data_elmt_in_rcd_id;
  FETCH c_new_data_elmt_in_rcd_id INTO l_new_data_elmt_in_rcd_id;
  CLOSE c_new_data_elmt_in_rcd_id;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_new_data_elmt_in_rcd_id;


END; -- get_new_WCRInF_DInR_id

-- ----------------------------------------------------------------------------
-- |------------------------< GET_NEW_RCD_ID >--------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_new_rcd_id(p_curr_rcd_id		IN NUMBER
		       ,p_new_extract_name	IN VARCHAR2
                       ,p_business_group_id     in number default null
		       ) RETURN NUMBER IS

  CURSOR c_new_rcd_id IS
  SELECT ext_rcd_id
  FROM ben_ext_rcd
  WHERE (p_business_group_id is null
        or p_business_group_id = business_group_id)
   and  name = (SELECT fix_name_length(p_new_extract_name||' '||name
  				      ,c_ExtName_Maxlen)
  		FROM ben_ext_rcd
  		WHERE ext_rcd_id = p_curr_rcd_id);

  l_new_rcd_id	NUMBER(15) := NULL;
  l_proc 	VARCHAR2(72) := g_package||'get_new_rcd_id';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN c_new_rcd_id;
  FETCH c_new_rcd_id into l_new_rcd_id;
  CLOSE c_new_rcd_id;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  RETURN l_new_rcd_id;

END; -- get_new_rcd_id

-- ----------------------------------------------------------------------------
-- |------------------------< GET_NEW_FORMULA_ID >----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_new_formula_id(p_new_formula_name	IN VARCHAR2
			   ,p_business_group_id	IN NUMBER
			   ) RETURN NUMBER IS

  CURSOR c_formula_id IS
  SELECT  formula_id
  FROM ff_formulas_f
  WHERE formula_name = p_new_formula_name
    AND business_group_id = p_business_group_id
    AND legislation_code IS NULL;

  l_formula_id	NUMBER(9);
  l_proc 			VARCHAR2(72) := g_package||'get_new_formula_id';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN c_formula_id;
  FETCH c_formula_id INTO l_formula_id;
  CLOSE c_formula_id;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_formula_id;

END; -- get_new_formula_id

-- ----------------------------------------------------------------------------
-- |------------------------< COPY_FORMULA >----------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION copy_formula(p_curr_formula_id		IN NUMBER
		     ,p_new_extract_name	IN VARCHAR2
		     ,p_business_group_id	IN NUMBER
		     ,p_legislation_code	IN VARCHAR2
		     ) RETURN NUMBER IS

  CURSOR c_formula IS
  SELECT  *
  FROM ff_formulas_f
  WHERE formula_id = p_curr_formula_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
              OR (legislation_code IS NOT NULL
                    AND legislation_code = p_legislation_code)
              OR (business_group_id IS NOT NULL
                    AND business_group_id = p_business_group_id)
        );

  -- Local Record Variables
  r_curr_formula	c_formula%ROWTYPE;

  -- Local Variables
  l_new_formula_id		NUMBER(15);
  l_new_formula_name		ff_formulas_f.formula_name%TYPE;
  l_new_row_id			ROWID;
  l_new_last_update_date	DATE;
  l_proc 			VARCHAR2(72) := g_package||'copy_formula';

  l_msg_name			varchar2(80);		-- bug 2459050
  l_FF93_FORMULA_txt		varchar2(80);

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN c_formula;
  FETCH c_formula INTO r_curr_formula;
  CLOSE c_formula;

  l_new_row_id		 := NULL;
  l_new_formula_id	 := NULL;

  -- Changed for UTF8
  -- l_new_formula_name	 := upper(p_new_extract_name)||'_'||r_curr_formula.formula_name;
  -- l_new_formula_name	 := fix_name_length(l_new_formula_name, c_FFName_Maxlen);
  l_new_formula_name	 := fix_name_length(upper(p_new_extract_name)||'_'||r_curr_formula.formula_name
    					   ,c_FFName_Maxlen
  					   );
  l_new_last_update_date := r_curr_formula.last_update_date;


  BEGIN  -- Insert into FF_FORMULAS_F using Row Handler
    ff_formulas_f_pkg.insert_Row(
                                 X_Rowid                => l_new_row_id -- IN OUT
                                ,X_Formula_Id           => l_new_formula_id -- IN OUT
                                ,X_Effective_Start_Date => r_curr_formula.effective_start_date
                                ,X_Effective_End_Date   => r_curr_formula.effective_end_date
                                ,X_Business_Group_Id    => p_business_group_id
                                ,X_Legislation_Code     => NULL
                                ,X_Formula_Type_Id      => r_curr_formula.formula_type_id
                                ,X_Formula_Name         => l_new_formula_name -- IN OUT
                                ,X_Description          => r_curr_formula.description
                                ,X_Formula_Text         => r_curr_formula.formula_text
                                ,X_Sticky_Flag          => r_curr_formula.sticky_Flag
                                ,X_Last_Update_Date     => l_new_last_update_date -- IN OUT
                                );

    -- Add the new formula id to list
    add_formula_id(l_new_formula_id);

  EXCEPTION

    WHEN OTHERS THEN
      --
      -- bug 2459050 - this error needs to be reported, hence replacing RAISE with
      -- fnd_message.raise_error
      --
      l_msg_name := get_msg_name();
      IF l_msg_name <> 'FF52_NAME_ALREADY_USED' THEN
        --
        fnd_message.set_name ('FF', 'FF93_FORMULA');
        l_FF93_FORMULA_txt := fnd_message.get;
        --
        fnd_message.set_name (g_msg_app, l_msg_name);
        if (l_msg_name = 'FFHR_6016_ALL_RES_WORDS') then
          fnd_message.set_token('VALUE_NAME', nvl(l_new_formula_name, l_FF93_FORMULA_txt) );
        end if;
        fnd_message.raise_error;
    	-- RAISE;
    	-- end fix 2459050
      ELSE
        -- Formula already created, find new formula Id here
        l_new_formula_id := get_new_formula_id(l_new_formula_name
      					      ,p_business_group_id
      					      );
      END IF; -- get_msg_name() <> 'FF52_NAME_ALREADY_USED'

  END; -- Insert into FF_FORMULAS_F using Row Handler

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  RETURN l_new_formula_id;

END; -- copy_formula

-- ----------------------------------------------------------------------------
-- |------------------------< COPY_CRITERIA_DEFINITION >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE copy_criteria_definition(p_ext_crit_prfl_id		IN NUMBER
    			           ,p_new_extract_name		IN VARCHAR2
    			           ,p_business_group_id		IN NUMBER
    			           ,p_legislation_code		IN VARCHAR2
    			           ,p_effective_date		IN DATE
    			           ,p_new_ext_crit_prfl_id  OUT NOCOPY NUMBER
    			           ) IS

  CURSOR c_ext_crit_prfl IS
  SELECT *
  FROM ben_ext_crit_prfl
  WHERE ext_crit_prfl_id = p_ext_crit_prfl_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
              OR (legislation_code IS NOT NULL
                    AND legislation_code = p_legislation_code)
              OR (business_group_id IS NOT NULL
                    AND business_group_id = p_business_group_id)
        );


  CURSOR c_ext_crit_typ(p_ext_crit_prfl_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_crit_typ
  WHERE ext_crit_prfl_id = p_ext_crit_prfl_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
              OR (legislation_code IS NOT NULL
                    AND legislation_code = p_legislation_code)
              OR (business_group_id IS NOT NULL
                    AND business_group_id = p_business_group_id)
        );

  CURSOR c_ext_crit_val(p_ext_crit_typ_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_crit_val
  WHERE ext_crit_typ_id = p_ext_crit_typ_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
              OR (legislation_code IS NOT NULL
                    AND legislation_code = p_legislation_code)
              OR (business_group_id IS NOT NULL
                    AND business_group_id = p_business_group_id)
        );

  CURSOR c_ext_crit_cmbn(p_ext_crit_val_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_crit_cmbn
  WHERE ext_crit_val_id = p_ext_crit_val_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
              OR (legislation_code IS NOT NULL
                    AND legislation_code = p_legislation_code)
              OR (business_group_id IS NOT NULL
                    AND business_group_id = p_business_group_id)
        );

  -- Local Record Variables
  r_curr_ext_crit_prlf		c_ext_crit_prfl%ROWTYPE;
  r_curr_ext_crit_typ		c_ext_crit_typ%ROWTYPE;
  r_curr_ext_crit_val		c_ext_crit_val%ROWTYPE;
  r_curr_ext_crit_cmbn		c_ext_crit_cmbn%ROWTYPE;


  -- Local Variables
  l_new_ext_crit_prfl_id	NUMBER(15);
  l_new_ext_crit_typ_id		NUMBER(15);
  l_new_ext_crit_val_id		NUMBER(15);
  l_new_ext_crit_cmbn_id	NUMBER(15);
  l_new_val_1			ben_ext_crit_val.val_1%type ;


  l_new_object_version_number   NUMBER(9);
  l_proc 			VARCHAR2(72) := g_package||'copy_criteria_definition';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  FOR r_curr_ext_crit_prfl IN c_ext_crit_prfl
  LOOP -- 2 Get Criteria Profile data for current EXT_DFN_ID

    -- Insert into BEN_EXT_CRIT_PRFL using Row Handler
    ben_xcr_ins.ins
        (
         p_ext_crit_prfl_id              => l_new_ext_crit_prfl_id  -- OUT
        ,p_name                          => fix_name_length
        				    (p_new_extract_name||' '||r_curr_ext_crit_prfl.name
        				    ,c_ExtName_Maxlen)
        ,p_business_group_id             => p_business_group_id
        ,p_legislation_code              => NULL
        ,p_xcr_attribute_category        => r_curr_ext_crit_prfl.xcr_attribute_category
        ,p_xcr_attribute1                => r_curr_ext_crit_prfl.xcr_attribute1
        ,p_xcr_attribute2                => r_curr_ext_crit_prfl.xcr_attribute2
        ,p_xcr_attribute3                => r_curr_ext_crit_prfl.xcr_attribute3
        ,p_xcr_attribute4                => r_curr_ext_crit_prfl.xcr_attribute4
        ,p_xcr_attribute5                => r_curr_ext_crit_prfl.xcr_attribute5
        ,p_xcr_attribute6                => r_curr_ext_crit_prfl.xcr_attribute6
        ,p_xcr_attribute7                => r_curr_ext_crit_prfl.xcr_attribute7
        ,p_xcr_attribute8                => r_curr_ext_crit_prfl.xcr_attribute8
        ,p_xcr_attribute9                => r_curr_ext_crit_prfl.xcr_attribute9
        ,p_xcr_attribute10               => r_curr_ext_crit_prfl.xcr_attribute10
        ,p_xcr_attribute11               => r_curr_ext_crit_prfl.xcr_attribute11
        ,p_xcr_attribute12               => r_curr_ext_crit_prfl.xcr_attribute12
        ,p_xcr_attribute13               => r_curr_ext_crit_prfl.xcr_attribute13
        ,p_xcr_attribute14               => r_curr_ext_crit_prfl.xcr_attribute14
        ,p_xcr_attribute15               => r_curr_ext_crit_prfl.xcr_attribute15
        ,p_xcr_attribute16               => r_curr_ext_crit_prfl.xcr_attribute16
        ,p_xcr_attribute17               => r_curr_ext_crit_prfl.xcr_attribute17
        ,p_xcr_attribute18               => r_curr_ext_crit_prfl.xcr_attribute18
        ,p_xcr_attribute19               => r_curr_ext_crit_prfl.xcr_attribute19
        ,p_xcr_attribute20               => r_curr_ext_crit_prfl.xcr_attribute20
        ,p_xcr_attribute21               => r_curr_ext_crit_prfl.xcr_attribute21
        ,p_xcr_attribute22               => r_curr_ext_crit_prfl.xcr_attribute22
        ,p_xcr_attribute23               => r_curr_ext_crit_prfl.xcr_attribute23
        ,p_xcr_attribute24               => r_curr_ext_crit_prfl.xcr_attribute24
        ,p_xcr_attribute25               => r_curr_ext_crit_prfl.xcr_attribute25
        ,p_xcr_attribute26               => r_curr_ext_crit_prfl.xcr_attribute26
        ,p_xcr_attribute27               => r_curr_ext_crit_prfl.xcr_attribute27
        ,p_xcr_attribute28               => r_curr_ext_crit_prfl.xcr_attribute28
        ,p_xcr_attribute29               => r_curr_ext_crit_prfl.xcr_attribute29
        ,p_xcr_attribute30               => r_curr_ext_crit_prfl.xcr_attribute30
        ,p_ext_global_flag               => nvl(r_curr_ext_crit_prfl.ext_global_flag, 'N')
        ,p_object_version_number         => l_new_object_version_number  -- OUT
        );

    FOR r_curr_ext_crit_typ IN c_ext_crit_typ(r_curr_ext_crit_prfl.ext_crit_prfl_id)
    LOOP -- 3 Get Criteria Type data for current EXT_CRIT_PRFL_ID

      -- Insert into BEN_EXT_CRIT_TYP using Row Handler
      ben_xct_ins.ins
            (
             p_ext_crit_typ_id               => l_new_ext_crit_typ_id -- OUT
            ,p_crit_typ_cd                   => r_curr_ext_crit_typ.crit_typ_cd
            ,p_ext_crit_prfl_id              => l_new_ext_crit_prfl_id
            ,p_business_group_id             => p_business_group_id
            ,p_legislation_code              => NULL
            ,p_object_version_number         => l_new_object_version_number -- OUT
            ,p_effective_date                => p_effective_date
            ,p_excld_flag                    => r_curr_ext_crit_typ.excld_flag
            );

      FOR r_curr_ext_crit_val IN c_ext_crit_val(r_curr_ext_crit_typ.ext_crit_typ_id)
      LOOP -- 4 Get Criteria Value data for current EXT_CRIT_TYP_ID

        /* IF Data Element Type = RULE then
	   Copy Formula and obtain new DATA_ELMT_RL */
	l_new_val_1 := NULL;

	IF r_curr_ext_crit_typ.crit_typ_cd = 'PRL' THEN

	  l_new_val_1 :=
	      copy_formula(
	                   p_curr_formula_id	=> r_curr_ext_crit_val.val_1
	                  ,p_new_extract_name	=> p_new_extract_name
	                  ,p_business_group_id	=> p_business_group_id
	                  ,p_legislation_code	=> p_legislation_code
	                  );

	ELSE
	  l_new_val_1 := r_curr_ext_crit_val.val_1;
	END IF; -- r_curr_ext_crit_typ.crit_typ_cd = 'PRL'

        -- Insert into BEN_EXT_CRIT_VAL using Row Handler
        ben_xcv_ins.ins
	        (
	         p_effective_date                => p_effective_date
	        ,p_ext_crit_val_id               => l_new_ext_crit_val_id -- OUT
	        ,p_val_1                         => l_new_val_1
	        ,p_val_2                         => r_curr_ext_crit_val.val_2
	        ,p_ext_crit_typ_id               => l_new_ext_crit_typ_id
	        ,p_business_group_id             => p_business_group_id
	        ,p_legislation_code              => NULL
	        ,p_ext_crit_bg_id                => r_curr_ext_crit_val.ext_crit_bg_id
	        ,p_object_version_number         => l_new_object_version_number -- OUT
	        );

        FOR r_curr_ext_crit_cmbn IN c_ext_crit_cmbn(r_curr_ext_crit_val.ext_crit_val_id)
        LOOP -- 5 Get Criteria Combination data for current EXT_CRIT_VAL_ID

          -- Insert into BEN_EXT_CRIT_CMBN using Row Handler
          ben_xcc_ins.ins
	            (
	             p_ext_crit_cmbn_id              => l_new_ext_crit_cmbn_id -- OUT
	            ,p_crit_typ_cd                   => r_curr_ext_crit_cmbn.crit_typ_cd
	            ,p_oper_cd                       => r_curr_ext_crit_cmbn.oper_cd
	            ,p_val_1                         => r_curr_ext_crit_cmbn.val_1
	            ,p_val_2                         => r_curr_ext_crit_cmbn.val_2
	            ,p_ext_crit_val_id               => l_new_ext_crit_val_id
	            ,p_business_group_id             => p_business_group_id
	            ,p_legislation_code              => NULL
	            ,p_object_version_number         => l_new_object_version_number -- OUT
	            ,p_effective_date                => p_effective_date
	            );

        END LOOP; -- 5

      END LOOP; -- 4

    END LOOP; -- 3

  END LOOP; -- 2

  -- Assign the New Extract Criteria Profile Id to return variable
  p_new_ext_crit_prfl_id := l_new_ext_crit_prfl_id;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

END copy_criteria_definition; -- copy_criteria_definition


-- ----------------------------------------------------------------------------
-- |------------------------< COPY_FILE_LAYOUT >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE copy_file_layout(p_ext_file_id		IN NUMBER
			  ,p_new_extract_name		IN VARCHAR2
			  ,p_business_group_id		IN NUMBER
			  ,p_legislation_code		IN VARCHAR2
			  ,p_effective_date		IN DATE
			  ,p_new_ext_file_id	 OUT NOCOPY NUMBER
			  ) IS

  CURSOR c_ext_file IS
  SELECT *
  FROM ben_ext_file
  WHERE ext_file_id = p_ext_file_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_ext_rcd_in_file(p_ext_file_id IN NUMBER) IS
  SELECT  RinF.*
  FROM ben_ext_rcd_in_file RinF, ben_ext_rcd Rcd
  WHERE RinF.ext_file_id = p_ext_file_id
    AND RinF.ext_rcd_id = Rcd.ext_rcd_id
    AND ((RinF.business_group_id IS NULL AND RinF.legislation_code IS NULL)
          OR (RinF.legislation_code IS NOT NULL
                AND RinF.legislation_code = p_legislation_code)
          OR (RinF.business_group_id IS NOT NULL
                AND RinF.business_group_id = p_business_group_id)
        )
  ORDER BY decode(Rcd.rcd_type_cd,'D',1,'H',2,'T',3)
          ,RinF.seq_num;

  CURSOR c_ext_rcd(p_ext_rcd_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_rcd
  WHERE ext_rcd_id = p_ext_rcd_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_RinF_where_clause(p_ext_rcd_in_file_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_where_clause
  WHERE ext_rcd_in_file_id = p_ext_rcd_in_file_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_RinF_incl_chg(p_ext_rcd_in_file_id IN NUMBER) IS
  SELECT * from ben_ext_incl_chg
  WHERE ext_rcd_in_file_id = p_ext_rcd_in_file_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_ext_data_elmt_in_rcd(p_ext_rcd_id IN NUMBER) IS
  SELECT DinR.*
  FROM ben_ext_data_elmt_in_rcd DinR, ben_ext_data_elmt DElmt
  WHERE DinR.ext_rcd_id = p_ext_rcd_id
    AND Dinr.ext_data_elmt_id = DElmt.ext_data_elmt_id
    AND ((DinR.business_group_id IS NULL AND DinR.legislation_code IS NULL)
          OR (DinR.legislation_code IS NOT NULL
                AND DinR.legislation_code = p_legislation_code)
          OR (DinR.business_group_id IS NOT NULL
                AND DinR.business_group_id = p_business_group_id)
        )
  ORDER BY decode(DElmt.data_elmt_typ_cd,'T',1,'C',2,0), DinR.seq_num;

  CURSOR c_ext_data_elmt(p_ext_data_elmt_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_data_elmt
  WHERE ext_data_elmt_id = p_ext_data_elmt_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_ext_data_elmt_decd(p_ext_data_elmt_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_data_elmt_decd
  WHERE ext_data_elmt_id = p_ext_data_elmt_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_DElmt_where_clause(p_ext_data_elmt_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_where_clause
  WHERE ext_data_elmt_id = p_ext_data_elmt_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_DinR_where_clause(p_ext_data_elmt_in_rcd_id IN NUMBER) IS
  SELECT *
  FROM ben_ext_where_clause
  WHERE ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  CURSOR c_DinR_incl_chg(p_ext_data_elmt_in_rcd_id IN NUMBER) IS
  SELECT * from ben_ext_incl_chg
  WHERE ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  -- Local Record Variables

  r_curr_ext_file		c_ext_file%ROWTYPE;
  r_curr_ext_rcd_in_file	c_ext_rcd_in_file%ROWTYPE;
  r_curr_ext_rcd		c_ext_rcd%ROWTYPE;
  r_curr_RinF_where_clause	c_RinF_where_clause%ROWTYPE;
  r_curr_RinF_incl_chg 		c_RinF_incl_chg%ROWTYPE;
  r_curr_data_elmt_in_rcd 	c_ext_data_elmt_in_rcd%ROWTYPE;
  r_curr_ext_data_elmt		c_ext_data_elmt%ROWTYPE;
  r_curr_ext_data_elmt_decd	c_ext_data_elmt_decd%ROWTYPE;
  r_curr_DElmt_where_clause	c_DElmt_where_clause%ROWTYPE;
  r_curr_DinR_where_clause	c_DinR_where_clause%ROWTYPE;
  r_curr_DinR_incl_chg		c_DinR_incl_chg%ROWTYPE;

  r_DinRId			IdTyp;
  r_RinFId			IdTyp;

  -- Local Variables
  l_new_ext_file_id			NUMBER(15);
  l_new_ext_rcd_id			NUMBER(15);
  l_new_ext_rcd_in_file_id		NUMBER(15);
  l_new_cond_data_elmt_in_rcd_id	NUMBER(15);
  l_new_RinF_where_clause_id		NUMBER(15);
  l_new_RinF_incl_chg_id		NUMBER(15);
  l_new_ext_data_elmt_id		NUMBER(15);
  l_new_ext_data_elmt_in_rcd_id		NUMBER(15);
  l_new_ttl_cond_data_elmt_id		NUMBER(15);
  l_new_ttl_sum_ext_data_elmt_id	NUMBER(15);
  l_new_ext_data_elmt_decd_id		NUMBER(15);
  l_new_DElmt_where_clause_id		NUMBER(15);
  l_new_cond_ext_data_elmt_id		NUMBER(15);
  l_new_DinR_where_clause_id		NUMBER(15);
  l_new_DinR_incl_chg_id		NUMBER(15);
  l_new_data_elmt_rl			NUMBER(15);


  l_rcd_present			BOOLEAN;
  l_data_elmt_present		BOOLEAN;

  l_new_object_version_number	NUMBER;
  l_proc 			VARCHAR2(72) := g_package||'copy_file_layout';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  FOR r_curr_ext_file IN c_ext_file
  LOOP -- 6 Get File Layout data for current EXT_DFN_ID

    -- Insert into BEN_EXT_FILE using Row Handler
    ben_xfi_ins.ins
        (
         p_ext_file_id                   => l_new_ext_file_id -- OUT
        ,p_name                          => fix_name_length
        				    (p_new_extract_name||' '||r_curr_ext_file.name
        				    ,c_ExtName_Maxlen)
        ,p_xml_tag_name                  =>  r_curr_ext_file.xml_tag_name
        ,p_business_group_id             => p_business_group_id
        ,p_legislation_code              => NULL
        ,p_xfi_attribute_category        => r_curr_ext_file.xfi_attribute_category
        ,p_xfi_attribute1                => r_curr_ext_file.xfi_attribute1
        ,p_xfi_attribute2                => r_curr_ext_file.xfi_attribute2
        ,p_xfi_attribute3                => r_curr_ext_file.xfi_attribute3
        ,p_xfi_attribute4                => r_curr_ext_file.xfi_attribute4
        ,p_xfi_attribute5                => r_curr_ext_file.xfi_attribute5
        ,p_xfi_attribute6                => r_curr_ext_file.xfi_attribute6
        ,p_xfi_attribute7                => r_curr_ext_file.xfi_attribute7
        ,p_xfi_attribute8                => r_curr_ext_file.xfi_attribute8
        ,p_xfi_attribute9                => r_curr_ext_file.xfi_attribute9
        ,p_xfi_attribute10               => r_curr_ext_file.xfi_attribute10
        ,p_xfi_attribute11               => r_curr_ext_file.xfi_attribute11
        ,p_xfi_attribute12               => r_curr_ext_file.xfi_attribute12
        ,p_xfi_attribute13               => r_curr_ext_file.xfi_attribute13
        ,p_xfi_attribute14               => r_curr_ext_file.xfi_attribute14
        ,p_xfi_attribute15               => r_curr_ext_file.xfi_attribute15
        ,p_xfi_attribute16               => r_curr_ext_file.xfi_attribute16
        ,p_xfi_attribute17               => r_curr_ext_file.xfi_attribute17
        ,p_xfi_attribute18               => r_curr_ext_file.xfi_attribute18
        ,p_xfi_attribute19               => r_curr_ext_file.xfi_attribute19
        ,p_xfi_attribute20               => r_curr_ext_file.xfi_attribute20
        ,p_xfi_attribute21               => r_curr_ext_file.xfi_attribute21
        ,p_xfi_attribute22               => r_curr_ext_file.xfi_attribute22
        ,p_xfi_attribute23               => r_curr_ext_file.xfi_attribute23
        ,p_xfi_attribute24               => r_curr_ext_file.xfi_attribute24
        ,p_xfi_attribute25               => r_curr_ext_file.xfi_attribute25
        ,p_xfi_attribute26               => r_curr_ext_file.xfi_attribute26
        ,p_xfi_attribute27               => r_curr_ext_file.xfi_attribute27
        ,p_xfi_attribute28               => r_curr_ext_file.xfi_attribute28
        ,p_xfi_attribute29               => r_curr_ext_file.xfi_attribute29
        ,p_xfi_attribute30               => r_curr_ext_file.xfi_attribute30
        ,p_object_version_number         => l_new_object_version_number -- OUT
        );

    -- Reset collection for Data Element in Record
    t_RinFId := NULL;

    FOR r_curr_ext_rcd_in_file IN c_ext_rcd_in_file(r_curr_ext_file.ext_file_id)
    LOOP /* 7 Get Record in File data for current EXT_FILE_ID
		order by Record Type(Detail, then Header, then Trailer)	 */
      FOR r_curr_ext_rcd IN c_ext_rcd(r_curr_ext_rcd_in_file.ext_rcd_id)
      LOOP -- 8 Get Record data for current EXT_RCD_ID

        BEGIN -- Insert into BEN_EXT_RCD using Row Handler
          l_rcd_present := FALSE;
          ben_xrc_ins.ins
	      (
	       p_ext_rcd_id                    => l_new_ext_rcd_id -- OUT
	      ,p_name                          => fix_name_length
        				    	  (p_new_extract_name||' '||r_curr_ext_rcd.name
        				    	  ,c_ExtName_Maxlen)
              ,p_xml_tag_name                  => r_curr_ext_rcd.xml_tag_name
	      ,p_rcd_type_cd                   => r_curr_ext_rcd.rcd_type_cd
	      ,p_low_lvl_cd                    => r_curr_ext_rcd.low_lvl_cd
	      ,p_business_group_id             => p_business_group_id
	      ,p_legislation_code              => NULL
	      ,p_xrc_attribute_category        => r_curr_ext_rcd.xrc_attribute_category
	      ,p_xrc_attribute1                => r_curr_ext_rcd.xrc_attribute1
	      ,p_xrc_attribute2                => r_curr_ext_rcd.xrc_attribute2
	      ,p_xrc_attribute3                => r_curr_ext_rcd.xrc_attribute3
	      ,p_xrc_attribute4                => r_curr_ext_rcd.xrc_attribute4
	      ,p_xrc_attribute5                => r_curr_ext_rcd.xrc_attribute5
	      ,p_xrc_attribute6                => r_curr_ext_rcd.xrc_attribute6
	      ,p_xrc_attribute7                => r_curr_ext_rcd.xrc_attribute7
	      ,p_xrc_attribute8                => r_curr_ext_rcd.xrc_attribute8
	      ,p_xrc_attribute9                => r_curr_ext_rcd.xrc_attribute9
	      ,p_xrc_attribute10               => r_curr_ext_rcd.xrc_attribute10
	      ,p_xrc_attribute11               => r_curr_ext_rcd.xrc_attribute11
	      ,p_xrc_attribute12               => r_curr_ext_rcd.xrc_attribute12
	      ,p_xrc_attribute13               => r_curr_ext_rcd.xrc_attribute13
	      ,p_xrc_attribute14               => r_curr_ext_rcd.xrc_attribute14
	      ,p_xrc_attribute15               => r_curr_ext_rcd.xrc_attribute15
	      ,p_xrc_attribute16               => r_curr_ext_rcd.xrc_attribute16
	      ,p_xrc_attribute17               => r_curr_ext_rcd.xrc_attribute17
	      ,p_xrc_attribute18               => r_curr_ext_rcd.xrc_attribute18
	      ,p_xrc_attribute19               => r_curr_ext_rcd.xrc_attribute19
	      ,p_xrc_attribute20               => r_curr_ext_rcd.xrc_attribute20
	      ,p_xrc_attribute21               => r_curr_ext_rcd.xrc_attribute21
	      ,p_xrc_attribute22               => r_curr_ext_rcd.xrc_attribute22
	      ,p_xrc_attribute23               => r_curr_ext_rcd.xrc_attribute23
	      ,p_xrc_attribute24               => r_curr_ext_rcd.xrc_attribute24
	      ,p_xrc_attribute25               => r_curr_ext_rcd.xrc_attribute25
	      ,p_xrc_attribute26               => r_curr_ext_rcd.xrc_attribute26
	      ,p_xrc_attribute27               => r_curr_ext_rcd.xrc_attribute27
	      ,p_xrc_attribute28               => r_curr_ext_rcd.xrc_attribute28
	      ,p_xrc_attribute29               => r_curr_ext_rcd.xrc_attribute29
	      ,p_xrc_attribute30               => r_curr_ext_rcd.xrc_attribute30
	      ,p_object_version_number         => l_new_object_version_number -- OUT
	      ,p_effective_date                => trunc(p_effective_date)
	      );
        EXCEPTION
          WHEN OTHERS THEN

            IF get_msg_name() <> 'BEN_91009_NAME_NOT_UNIQUE' THEN
              RAISE;
            ELSE
              l_rcd_present := TRUE;
              l_new_ext_rcd_id := get_new_rcd_id(
              					 r_curr_ext_rcd.ext_rcd_id
              					,p_new_extract_name
                                                ,p_business_group_id
              					);
            END IF;

        END; -- Insert into BEN_EXT_RCD using Row Handler

        -- Insert into BEN_EXT_RCD_IN_FILE using Row Handler
        ben_xrf_ins.ins
	    (
	     p_ext_rcd_in_file_id            => l_new_ext_rcd_in_file_id -- OUT
	    ,p_seq_num                       => r_curr_ext_rcd_in_file.seq_num
	    ,p_sprs_cd                       => r_curr_ext_rcd_in_file.sprs_cd
	    ,p_sort1_data_elmt_in_rcd_id     => r_curr_ext_rcd_in_file.sort1_data_elmt_in_rcd_id
	    ,p_sort2_data_elmt_in_rcd_id     => r_curr_ext_rcd_in_file.sort2_data_elmt_in_rcd_id
	    ,p_sort3_data_elmt_in_rcd_id     => r_curr_ext_rcd_in_file.sort3_data_elmt_in_rcd_id
	    ,p_sort4_data_elmt_in_rcd_id     => r_curr_ext_rcd_in_file.sort4_data_elmt_in_rcd_id
	    ,p_ext_rcd_id                    => l_new_ext_rcd_id
	    ,p_ext_file_id                   => l_new_ext_file_id
	    ,p_business_group_id             => p_business_group_id
	    ,p_legislation_code              => NULL
	    ,p_object_version_number         => l_new_object_version_number -- OUT
	    ,p_any_or_all_cd                 => r_curr_ext_rcd_in_file.any_or_all_cd
	    ,p_hide_flag                     => r_curr_ext_rcd_in_file.hide_flag
	    ,p_rqd_flag                      => r_curr_ext_rcd_in_file.rqd_flag
	    ,p_CHG_RCD_UPD_FLAG              => r_curr_ext_rcd_in_file.CHG_RCD_UPD_FLAG
	    ,p_effective_date                => trunc(p_effective_date)
	    );

        IF NOT l_rcd_present THEN

          -- Reset collection for Data Element in Record
          t_DinRId := NULL;

          FOR r_curr_data_elmt_in_rcd IN c_ext_data_elmt_in_rcd(r_curr_ext_rcd.ext_rcd_id)
          LOOP /* 9 Get Data Element in Record data for current EXT_RCD_ID
  				order by Data element Type(Total Type last) */
            FOR r_curr_data_elmt IN c_ext_data_elmt(r_curr_data_elmt_in_rcd.ext_data_elmt_id)
            LOOP -- 10 Get Data Element data for current EXT_DATA_ELMT_ID

              /* IF Data Element Type = RULE then
                 Copy Formula and obtain new DATA_ELMT_RL */
              l_new_data_elmt_rl := NULL;

              IF r_curr_data_elmt.data_elmt_typ_cd = 'R' THEN

                l_new_data_elmt_rl :=
                    copy_formula(
                                 p_curr_formula_id	=> r_curr_data_elmt.data_elmt_rl
                                ,p_new_extract_name	=> p_new_extract_name
                                ,p_business_group_id	=> p_business_group_id
                                ,p_legislation_code	=> p_legislation_code
                                );

              END IF; -- r_curr_data_elmt.data_elmt_typ_cd = 'R'

              /* IF Data Element Type = TOTAL then
                 Find new TTL_COND_EXT_DATA_ELMT_ID and maybe TTL_SUM_EXT_DATA_ELMT_ID */

              l_new_ttl_cond_data_elmt_id := NULL;
              l_new_ttl_sum_ext_data_elmt_id := NULL;

              IF r_curr_data_elmt.data_elmt_typ_cd in( 'T','C')  THEN

                -- Find new EXT_RCD_ID
                l_new_ttl_cond_data_elmt_id :=
                		get_new_rcd_id(
                			       r_curr_data_elmt.ttl_cond_ext_data_elmt_id
                			      ,p_new_extract_name
                                              ,p_business_group_id
                			      );

                -- Find new TTL_SUM_EXT_DATA_ELMT_ID only if current is not null
                IF r_curr_data_elmt.ttl_sum_ext_data_elmt_id IS NOT NULL THEN
                  l_new_ttl_sum_ext_data_elmt_id :=
                     get_new_data_elmt_id(
                     			r_curr_data_elmt.ttl_sum_ext_data_elmt_id
                     		       ,p_new_extract_name
                                       ,p_business_group_id
                     		       );
                END IF; -- r_curr_data_elmt.ttl_sum_ext_data_elmt_id IS NOT NULL

              END IF; -- r_curr_data_elmt.data_elmt_typ_cd = 'T'

              BEGIN -- Insert new record in BEN_EXT_DATA_ELMT with New Extract Name Prefixed
                l_data_elmt_present := FALSE;
                ben_xel_ins.ins
  	          (
  	           p_ext_data_elmt_id              => l_new_ext_data_elmt_id -- OUT
  	          ,p_name                          => fix_name_length
        				    	      (p_new_extract_name||' '||r_curr_data_elmt.name
        				    	      ,c_ExtName_Maxlen)
                  ,p_xml_tag_name                  => r_curr_data_elmt.xml_tag_name
  	          ,p_data_elmt_typ_cd              => r_curr_data_elmt.data_elmt_typ_cd
  	          ,p_data_elmt_rl                  => l_new_data_elmt_rl
  	          ,p_frmt_mask_cd                  => r_curr_data_elmt.frmt_mask_cd
  	          ,p_string_val                    => r_curr_data_elmt.string_val
  	          ,p_dflt_val                      => r_curr_data_elmt.dflt_val
  	          ,p_max_length_num                => r_curr_data_elmt.max_length_num
  	          ,p_just_cd                       => r_curr_data_elmt.just_cd
  	          ,p_ttl_fnctn_cd                  => r_curr_data_elmt.ttl_fnctn_cd
  	          ,p_ttl_cond_oper_cd              => r_curr_data_elmt.ttl_cond_oper_cd
  	          ,p_ttl_cond_val                  => r_curr_data_elmt.ttl_cond_val
  	          ,p_ttl_sum_ext_data_elmt_id      => l_new_ttl_sum_ext_data_elmt_id
  	          ,p_ttl_cond_ext_data_elmt_id     => l_new_ttl_cond_data_elmt_id
  	          ,p_ext_fld_id                    => r_curr_data_elmt.ext_fld_id
  	          ,p_business_group_id             => p_business_group_id
  	          ,p_legislation_code              => NULL
  	          ,p_xel_attribute_category        => r_curr_data_elmt.xel_attribute_category
  	          ,p_xel_attribute1                => r_curr_data_elmt.xel_attribute1
  	          ,p_xel_attribute2                => r_curr_data_elmt.xel_attribute2
  	          ,p_xel_attribute3                => r_curr_data_elmt.xel_attribute3
  	          ,p_xel_attribute4                => r_curr_data_elmt.xel_attribute4
  	          ,p_xel_attribute5                => r_curr_data_elmt.xel_attribute5
  	          ,p_xel_attribute6                => r_curr_data_elmt.xel_attribute6
  	          ,p_xel_attribute7                => r_curr_data_elmt.xel_attribute7
  	          ,p_xel_attribute8                => r_curr_data_elmt.xel_attribute8
  	          ,p_xel_attribute9                => r_curr_data_elmt.xel_attribute9
  	          ,p_xel_attribute10               => r_curr_data_elmt.xel_attribute10
  	          ,p_xel_attribute11               => r_curr_data_elmt.xel_attribute11
  	          ,p_xel_attribute12               => r_curr_data_elmt.xel_attribute12
  	          ,p_xel_attribute13               => r_curr_data_elmt.xel_attribute13
  	          ,p_xel_attribute14               => r_curr_data_elmt.xel_attribute14
  	          ,p_xel_attribute15               => r_curr_data_elmt.xel_attribute15
  	          ,p_xel_attribute16               => r_curr_data_elmt.xel_attribute16
  	          ,p_xel_attribute17               => r_curr_data_elmt.xel_attribute17
  	          ,p_xel_attribute18               => r_curr_data_elmt.xel_attribute18
  	          ,p_xel_attribute19               => r_curr_data_elmt.xel_attribute19
  	          ,p_xel_attribute20               => r_curr_data_elmt.xel_attribute20
  	          ,p_xel_attribute21               => r_curr_data_elmt.xel_attribute21
  	          ,p_xel_attribute22               => r_curr_data_elmt.xel_attribute22
  	          ,p_xel_attribute23               => r_curr_data_elmt.xel_attribute23
  	          ,p_xel_attribute24               => r_curr_data_elmt.xel_attribute24
  	          ,p_xel_attribute25               => r_curr_data_elmt.xel_attribute25
  	          ,p_xel_attribute26               => r_curr_data_elmt.xel_attribute26
  	          ,p_xel_attribute27               => r_curr_data_elmt.xel_attribute27
  	          ,p_xel_attribute28               => r_curr_data_elmt.xel_attribute28
  	          ,p_xel_attribute29               => r_curr_data_elmt.xel_attribute29
  	          ,p_xel_attribute30               => r_curr_data_elmt.xel_attribute30
  	          ,p_object_version_number         => l_new_object_version_number -- OUT
  	          ,p_effective_date                => trunc(p_effective_date)
                  ,p_defined_balance_id            => r_curr_data_elmt.defined_balance_id
  	          );
              EXCEPTION
  	      WHEN OTHERS THEN
  	        IF get_msg_name() <> 'BEN_91009_NAME_NOT_UNIQUE' THEN
  	          RAISE;
  	        ELSE
  	          l_data_elmt_present := TRUE;
  	          l_new_ext_data_elmt_id := get_new_data_elmt_id(
  	          						 r_curr_data_elmt.ext_data_elmt_id
  	          						,p_new_extract_name
                                                                ,p_business_group_id
  	          						);
  	        END IF;
              END; -- Insert into BEN_EXT_DATA_ELMT using Row Handler

              -- Insert new record in BEN_EXT_DATA_ELMT_IN_RCD using Row Handler
              ben_xer_ins.ins
  	            (
  	             p_ext_data_elmt_in_rcd_id       => l_new_ext_data_elmt_in_rcd_id -- OUT
  	            ,p_seq_num                       => r_curr_data_elmt_in_rcd.seq_num
  	            ,p_strt_pos                      => r_curr_data_elmt_in_rcd.strt_pos
  	            ,p_dlmtr_val                     => r_curr_data_elmt_in_rcd.dlmtr_val
  	            ,p_rqd_flag                      => r_curr_data_elmt_in_rcd.rqd_flag
  	            ,p_sprs_cd                       => r_curr_data_elmt_in_rcd.sprs_cd
  	            ,p_any_or_all_cd                 => r_curr_data_elmt_in_rcd.any_or_all_cd
  	            ,p_ext_data_elmt_id              => l_new_ext_data_elmt_id
  	            ,p_ext_rcd_id                    => l_new_ext_rcd_id
  	            ,p_business_group_id             => p_business_group_id
  	            ,p_legislation_code              => NULL
  	            ,p_object_version_number         => l_new_object_version_number -- OUT
  	            ,p_hide_flag                     => r_curr_data_elmt_in_rcd.hide_flag
  	            ,p_effective_date                => trunc(p_effective_date)
  	            );

              IF NOT l_data_elmt_present THEN

                -- IF Data Element Type = DECODE then copy data in BEN_EXT_DATA_ELMT_DECD
                IF r_curr_data_elmt.data_elmt_typ_cd = 'D' THEN

                  FOR r_curr_ext_data_elmt_decd IN c_ext_data_elmt_decd(r_curr_data_elmt.ext_data_elmt_id)
                  LOOP -- 11 Get Data Element Decode data for current EXT_DATA_ELMT_ID

                    -- Insert new record in BEN_EXT_DATA_ELMT_DECD using Row Handler
                    ben_xdd_ins.ins
		        (
		         p_ext_data_elmt_decd_id         => l_new_ext_data_elmt_decd_id -- OUT
		        ,p_val                           => r_curr_ext_data_elmt_decd.val
		        ,p_dcd_val                       => r_curr_ext_data_elmt_decd.dcd_val
		        ,p_ext_data_elmt_id              => l_new_ext_data_elmt_id
		        ,p_business_group_id             => p_business_group_id
		        ,p_legislation_code              => NULL
		        ,p_object_version_number         => l_new_object_version_number -- OUT
                        ,p_chg_evt_source                => r_curr_ext_data_elmt_decd.chg_evt_source
		        );

                  END LOOP; -- 11
                END IF; -- r_curr_data_elmt.data_elmt_typ_cd = 'D'

                -- IF Data Element Type = TOTAL then copy WHERE CLAUSE data
                IF r_curr_data_elmt.data_elmt_typ_cd in( 'T','C')  THEN

                  FOR r_curr_DElmt_where_clause IN c_DElmt_where_clause(r_curr_data_elmt.ext_data_elmt_id)
                  LOOP -- 12 Get Where Clause data for current EXT_DATA_ELMT_ID

                    /* For the data element in CONDITION, find the EX_DATA_ELMT_ID of
		       the NEW data element created */
		    l_new_cond_ext_data_elmt_id :=
		    	get_new_data_elmt_id(
		    			     r_curr_DElmt_where_clause.cond_ext_data_elmt_id
		    			    ,p_new_extract_name
                                            ,p_business_group_id
		    			    );

                    -- Insert new record in BEN_EXT_WHERE_CLAUSE using Row Handler
                    ben_xwc_ins.ins
		    	    (
		    	     p_ext_where_clause_id           => l_new_DElmt_where_clause_id -- OUT
		    	    ,p_seq_num                       => r_curr_DElmt_where_clause.seq_num
		    	    ,p_oper_cd                       => r_curr_DElmt_where_clause.oper_cd
		    	    ,p_val                           => r_curr_DElmt_where_clause.val
		    	    ,p_and_or_cd                     => r_curr_DElmt_where_clause.and_or_cd
		    	    ,p_ext_data_elmt_id              => l_new_ext_data_elmt_id
		    	    ,p_cond_ext_data_elmt_id         => l_new_cond_ext_data_elmt_id
		    	    ,p_ext_rcd_in_file_id            => NULL -- p_ext_rcd_in_file_id
		    	    ,p_ext_data_elmt_in_rcd_id       => NULL -- p_ext_data_elmt_in_rcd_id
		    	    ,p_business_group_id             => p_business_group_id
		    	    ,p_legislation_code              => NULL
		    	    ,p_object_version_number         => l_new_object_version_number -- OUT
		    	    ,p_cond_ext_data_elmt_in_rcd_id  => NULL -- p_cond_ext_data_elmt_in_rcd_id
		    	    ,p_effective_date                => trunc(p_effective_date)
		    	    );

                  END LOOP; -- 12

                END IF; -- r_curr_data_elmt.data_elmt_typ_cd = 'T'

              END IF; -- NOT l_data_elmt_present

            END LOOP; -- 10

            /* Add current EXT_DATA_ELMT_IN_RCD_ID to collection for
               processing of WHERE CLAUSE for Data Elemnt in Record  */
             add_DinR_id(r_curr_data_elmt_in_rcd.ext_data_elmt_in_rcd_id
             		,l_new_ext_data_elmt_in_rcd_id);


            FOR r_curr_DinR_incl_chg IN c_DinR_incl_chg(r_curr_data_elmt_in_rcd.ext_data_elmt_in_rcd_id)
            LOOP -- 16 Get Inclusion on Change Event data for current EXT_DATA_ELMT_IN_RCD_ID

              -- Insert into BEN_EXT_INCL_CHG using Row Handler
              ben_xic_ins.ins
            	    (
            	     p_ext_incl_chg_id               => l_new_DinR_incl_chg_id -- OUT
            	    ,p_chg_evt_cd                    => r_curr_DinR_incl_chg.chg_evt_cd
            	    ,p_ext_rcd_in_file_id            => NULL
            	    ,p_ext_data_elmt_in_rcd_id       => l_new_ext_data_elmt_in_rcd_id
            	    ,p_business_group_id             => p_business_group_id
            	    ,p_legislation_code              => NULL
            	    ,p_object_version_number         => l_new_object_version_number -- OUT
            	    ,p_effective_date                => trunc(p_effective_date)
                    ,p_chg_evt_source                => r_curr_DinR_incl_chg.chg_evt_source
            	    );

            END LOOP; -- 16

          END LOOP; -- 9

          IF t_DinRId IS NOT NULL THEN

            FOR l_DinRId_Indx IN t_DinRId.FIRST..t_DinRId.LAST
            LOOP -- 17 Process all Data_Elmt_In_Rcd_Id for Where Clause data

              r_DinRId := t_DinRId(l_DinRId_Indx);

              FOR r_curr_DinR_where_clause IN c_DinR_where_clause(r_DinRId.curr_Id)
    	      LOOP -- 13 Get Where Clause data for current EXT_DATA_ELMT_IN_RCD_ID

    	        /* For the data element in CONDITION, find the EXT_DATA_ELMT_ID of
    	           the NEW data element created */
    	        l_new_cond_data_elmt_in_rcd_id :=
    	    	  get_new_WCDInR_DInR_id(
    	    				      r_curr_DinR_where_clause.cond_ext_data_elmt_in_rcd_id
    	    				     ,l_new_ext_rcd_id
    	    				     ,p_new_extract_name
                                             ,p_business_group_id
    	    				     );

                 l_new_cond_ext_data_elmt_id := null  ;
                 if r_curr_DinR_where_clause.cond_ext_data_elmt_id  is not null then
                     l_new_cond_ext_data_elmt_id :=
                        get_new_data_elmt_id(
                                            r_curr_DinR_where_clause.cond_ext_data_elmt_id
                                            ,p_new_extract_name
                                            ,p_business_group_id
                                            );
                  end if ;


    	      -- Insert into BEN_EXT_WHERE_CLAUSE using Row Handler
    	        ben_xwc_ins.ins
    	    	  (
    	    	   p_ext_where_clause_id           => l_new_DinR_where_clause_id -- OUT
    	    	  ,p_seq_num                       => r_curr_DinR_where_clause.seq_num
    	    	  ,p_oper_cd                       => r_curr_DinR_where_clause.oper_cd
    	    	  ,p_val                           => r_curr_DinR_where_clause.val
    	    	  ,p_and_or_cd                     => r_curr_DinR_where_clause.and_or_cd
    	    	  ,p_ext_data_elmt_id              => NULL -- p_ext_data_elmt_id
    	    	  ,p_cond_ext_data_elmt_id         => l_new_cond_ext_data_elmt_id
    	    	  ,p_ext_rcd_in_file_id            => NULL -- p_ext_rcd_in_file_id
    	    	  ,p_ext_data_elmt_in_rcd_id       => r_DinRId.new_Id
    	    	  ,p_business_group_id             => p_business_group_id
    	    	  ,p_legislation_code              => NULL
    	    	  ,p_object_version_number         => l_new_object_version_number -- OUT
    	    	  ,p_cond_ext_data_elmt_in_rcd_id  => l_new_cond_data_elmt_in_rcd_id
    	    	  ,p_effective_date                => trunc(p_effective_date)
    	    	  );

              END LOOP; -- 13

            END LOOP; -- 17

            -- Reset collection for Data Element in Record
            t_DinRId := NULL;

          END IF; -- t_DinRId IS NOT NULL THEN

        END IF; -- NOT l_rcd_present

      END LOOP; -- 8

      /* Add current EXT_RCD_IN_FILE_ID to collection for
         processing of WHERE CLAUSE for Record in File */
      add_RinF_id(r_curr_ext_rcd_in_file.ext_rcd_in_file_id
      		 ,l_new_ext_rcd_in_file_id);

      FOR r_curr_RinF_incl_chg IN c_RinF_incl_chg(r_curr_ext_rcd_in_file.ext_rcd_in_file_id)
      LOOP -- 15 Get Inclusion on Change Event data for current EXT_RCD_IN_FILE_ID

        -- Insert into BEN_EXT_INCL_CHG using Row Handler
        ben_xic_ins.ins
	    (
	     p_ext_incl_chg_id               => l_new_RinF_incl_chg_id -- OUT
	    ,p_chg_evt_cd                    => r_curr_RinF_incl_chg.chg_evt_cd
	    ,p_ext_rcd_in_file_id            => l_new_ext_rcd_in_file_id
	    ,p_ext_data_elmt_in_rcd_id       => NULL
	    ,p_business_group_id             => p_business_group_id
	    ,p_legislation_code              => NULL
	    ,p_object_version_number         => l_new_object_version_number -- OUT
	    ,p_effective_date                => trunc(p_effective_date)
            ,p_chg_evt_source                => r_curr_RinF_incl_chg.chg_evt_source
	    );

      END LOOP; -- 15

    END LOOP; -- 7

    IF t_RinFId IS NOT NULL THEN

      FOR l_RinFId_Indx IN t_RinFId.FIRST..t_RinFId.LAST
      LOOP -- 18 Process all Rcd_In_File_Id for Where Clause data

        r_RinFId := t_RinFId(l_RinFId_Indx);

        FOR r_curr_RinF_where_clause IN c_RinF_where_clause(r_RinFId.curr_id)
        LOOP -- 14 Get Where Clause data for current EXT_RCD_IN_FILE_ID

          /* For the data element in CONDITION, find the EX_DATA_ELMT_ID of
             the NEW data element created */
          l_new_cond_data_elmt_in_rcd_id :=
          	get_new_WCRInF_DInR_id(
          			       r_curr_RinF_where_clause.cond_ext_data_elmt_in_rcd_id
          			      ,r_RinFId.new_id
          			      ,p_new_extract_name
          			      );


          l_new_cond_ext_data_elmt_id := null  ;
          if r_curr_RinF_where_clause.cond_ext_data_elmt_id  is not null then
              l_new_cond_ext_data_elmt_id :=
                   get_new_data_elmt_id(
                                   r_curr_RinF_where_clause.cond_ext_data_elmt_id
                                  ,p_new_extract_name
                                  ,p_business_group_id
                                 );
          end if ;


          -- Insert into BEN_EXT_WHERE_CLAUSE using Row Handler
          ben_xwc_ins.ins
  	    (
  	     p_ext_where_clause_id           => l_new_RinF_where_clause_id -- OUT
  	    ,p_seq_num                       => r_curr_RinF_where_clause.seq_num
  	    ,p_oper_cd                       => r_curr_RinF_where_clause.oper_cd
  	    ,p_val                           => r_curr_RinF_where_clause.val
  	    ,p_and_or_cd                     => r_curr_RinF_where_clause.and_or_cd
  	    ,p_ext_data_elmt_id              => NULL -- p_ext_data_elmt_id
  	    ,p_cond_ext_data_elmt_id         => l_new_cond_ext_data_elmt_id
  	    ,p_ext_rcd_in_file_id            => r_RinFId.new_id
  	    ,p_ext_data_elmt_in_rcd_id       => NULL -- p_ext_data_elmt_in_rcd_id
  	    ,p_business_group_id             => p_business_group_id
  	    ,p_legislation_code              => NULL
  	    ,p_object_version_number         => l_new_object_version_number -- OUT
  	    ,p_cond_ext_data_elmt_in_rcd_id  => l_new_cond_data_elmt_in_rcd_id
  	    ,p_effective_date                => trunc(p_effective_date)
  	    );

        END LOOP; -- 14

      END LOOP; -- 18

      -- Reset collection for Data Element in Record
      t_RinFId := NULL;

    END IF; -- t_RinFId IS NOT NULL


    -- Assign the New File Id to return variable
    p_new_ext_file_id := l_new_ext_file_id;

  END LOOP; -- 6

  hr_utility.set_location('Leaving:'|| l_proc, 20);

END copy_file_layout; -- copy_file_layout

-- ----------------------------------------------------------------------------
-- |------------------------< COPY_EXTRACT >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE copy_extract(p_extract_dfn_id 	IN NUMBER
		      ,p_new_extract_name 	IN VARCHAR2
		      ,p_business_group_id 	IN NUMBER
		      ,p_legislation_code	IN VARCHAR2
		      ,p_effective_date		IN DATE
		      ,p_formulas	 OUT NOCOPY FormulaID
		      ) IS

  CURSOR c_ext_dfn IS
  SELECT *
  FROM ben_ext_dfn
  WHERE ext_dfn_id = p_extract_dfn_id
    AND ((business_group_id IS NULL AND legislation_code IS NULL)
          OR (legislation_code IS NOT NULL
                AND legislation_code = p_legislation_code)
          OR (business_group_id IS NOT NULL
                AND business_group_id = p_business_group_id)
        );

  -- Local Record Variables
  r_curr_ext_dfn	c_ext_dfn%ROWTYPE;

  -- Local Variables
  l_new_ext_crit_prfl_id	NUMBER(15);
  l_new_ext_file_id		NUMBER(15);
  l_new_ext_dfn_id		NUMBER(15);
  l_new_object_version_number   NUMBER(9);
  l_new_post_prcs_rl		NUMBER(15);
  l_proc 			VARCHAR2(72) := g_package||'copy_extract';

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  IF p_new_extract_name IS NULL THEN
    fnd_message.set_name('PQP', 'PQP_230541_EXTRACT_PREFIX_NULL');
    fnd_message.raise_error;
  END IF;

  -- Set the truncation flag to false
  g_truncated := FALSE;

  FOR r_curr_ext_dfn in c_ext_dfn
  LOOP -- 1 Get Extract Definition data for p_ext_dfn_id

    -- Creteria Definition
    copy_criteria_definition(p_ext_crit_prfl_id		=> r_curr_ext_dfn.ext_crit_prfl_id
    			    ,p_new_extract_name		=> p_new_extract_name
    			    ,p_business_group_id	=> p_business_group_id
    			    ,p_legislation_code		=> p_legislation_code
    			    ,p_effective_date		=> p_effective_date
       			    ,p_new_ext_crit_prfl_id	=> l_new_ext_crit_prfl_id -- OUT
    			    );

    -- File Layouts
    copy_file_layout(p_ext_file_id		=> r_curr_ext_dfn.ext_file_id
    		    ,p_new_extract_name		=> p_new_extract_name
    		    ,p_business_group_id	=> p_business_group_id
    		    ,p_legislation_code		=> p_legislation_code
    		    ,p_effective_date		=> p_effective_date
    		    ,p_new_ext_file_id		=> l_new_ext_file_id -- OUT
    		    );

    -- If Post Processing Rule exists then copy formula and obtain new formula id
    l_new_post_prcs_rl := NULL;

    IF r_curr_ext_dfn.ext_post_prcs_rl IS NOT NULL THEN

      l_new_post_prcs_rl :=
          copy_formula(
                       p_curr_formula_id	=> r_curr_ext_dfn.ext_post_prcs_rl
                      ,p_new_extract_name	=> p_new_extract_name
                      ,p_business_group_id	=> p_business_group_id
                      ,p_legislation_code	=> p_legislation_code
                      );

    END IF; -- r_curr_ext_dfn.ext_post_prcs_rl IS NOT NULL


    -- Insert into BEN_EXT_DFN using Row Handler
    ben_xdf_ins.ins
      (p_ext_dfn_id                    => l_new_ext_dfn_id -- OUT
      ,p_name                          => fix_name_length
      					  (p_new_extract_name||' '||r_curr_ext_dfn.name
      					  ,c_ExtName_Maxlen)
      ,p_xml_tag_name                  => r_curr_ext_dfn.xml_tag_name
      ,p_data_typ_cd                   => r_curr_ext_dfn.data_typ_cd
      ,p_ext_typ_cd                    => r_curr_ext_dfn.ext_typ_cd
      ,p_output_name                   => r_curr_ext_dfn.output_name
      ,p_output_type                   => r_curr_ext_dfn.output_type
      ,p_apnd_rqst_id_flag             => r_curr_ext_dfn.apnd_rqst_id_flag
      ,p_prmy_sort_cd                  => r_curr_ext_dfn.prmy_sort_cd
      ,p_scnd_sort_cd                  => r_curr_ext_dfn.scnd_sort_cd
      ,p_strt_dt                       => r_curr_ext_dfn.strt_dt
      ,p_end_dt                        => r_curr_ext_dfn.end_dt
      ,p_ext_crit_prfl_id              => l_new_ext_crit_prfl_id
      ,p_ext_file_id                   => l_new_ext_file_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => NULL
      ,p_xdf_attribute_category        => r_curr_ext_dfn.xdf_attribute_category
      ,p_xdf_attribute1                => r_curr_ext_dfn.xdf_attribute1
      ,p_xdf_attribute2                => r_curr_ext_dfn.xdf_attribute2
      ,p_xdf_attribute3                => r_curr_ext_dfn.xdf_attribute3
      ,p_xdf_attribute4                => r_curr_ext_dfn.xdf_attribute4
      ,p_xdf_attribute5                => r_curr_ext_dfn.xdf_attribute5
      ,p_xdf_attribute6                => r_curr_ext_dfn.xdf_attribute6
      ,p_xdf_attribute7                => r_curr_ext_dfn.xdf_attribute7
      ,p_xdf_attribute8                => r_curr_ext_dfn.xdf_attribute8
      ,p_xdf_attribute9                => r_curr_ext_dfn.xdf_attribute9
      ,p_xdf_attribute10               => r_curr_ext_dfn.xdf_attribute10
      ,p_xdf_attribute11               => r_curr_ext_dfn.xdf_attribute11
      ,p_xdf_attribute12               => r_curr_ext_dfn.xdf_attribute12
      ,p_xdf_attribute13               => r_curr_ext_dfn.xdf_attribute13
      ,p_xdf_attribute14               => r_curr_ext_dfn.xdf_attribute14
      ,p_xdf_attribute15               => r_curr_ext_dfn.xdf_attribute15
      ,p_xdf_attribute16               => r_curr_ext_dfn.xdf_attribute16
      ,p_xdf_attribute17               => r_curr_ext_dfn.xdf_attribute17
      ,p_xdf_attribute18               => r_curr_ext_dfn.xdf_attribute18
      ,p_xdf_attribute19               => r_curr_ext_dfn.xdf_attribute19
      ,p_xdf_attribute20               => r_curr_ext_dfn.xdf_attribute20
      ,p_xdf_attribute21               => r_curr_ext_dfn.xdf_attribute21
      ,p_xdf_attribute22               => r_curr_ext_dfn.xdf_attribute22
      ,p_xdf_attribute23               => r_curr_ext_dfn.xdf_attribute23
      ,p_xdf_attribute24               => r_curr_ext_dfn.xdf_attribute24
      ,p_xdf_attribute25               => r_curr_ext_dfn.xdf_attribute25
      ,p_xdf_attribute26               => r_curr_ext_dfn.xdf_attribute26
      ,p_xdf_attribute27               => r_curr_ext_dfn.xdf_attribute27
      ,p_xdf_attribute28               => r_curr_ext_dfn.xdf_attribute28
      ,p_xdf_attribute29               => r_curr_ext_dfn.xdf_attribute29
      ,p_xdf_attribute30               => r_curr_ext_dfn.xdf_attribute30
      ,p_object_version_number         => l_new_object_version_number  -- OUT
      ,p_drctry_name                   => r_curr_ext_dfn.drctry_name
      ,p_kickoff_wrt_prc_flag          => r_curr_ext_dfn.kickoff_wrt_prc_flag
      ,p_upd_cm_sent_dt_flag           => r_curr_ext_dfn.upd_cm_sent_dt_flag
      ,p_spcl_hndl_flag                => r_curr_ext_dfn.spcl_hndl_flag
      ,p_use_eff_dt_for_chgs_flag      => r_curr_ext_dfn.use_eff_dt_for_chgs_flag
      ,p_ext_post_prcs_rl              => l_new_post_prcs_rl
      ,p_effective_date                => p_effective_date
      ,p_XDO_TEMPLATE_ID               => r_curr_ext_dfn.XDO_TEMPLATE_ID
      ,p_ext_global_flag               => nvl(r_curr_ext_dfn.ext_global_flag,'N')
      ,p_cm_display_flag               => nvl(r_curr_ext_dfn.cm_display_flag,'N')
      );

      -- Copy Extract Attributes
      pqp_copy_eat.copy_extract_attributes
      		  (p_curr_ext_dfn_id     => p_extract_dfn_id
      		  ,p_new_ext_dfn_id      => l_new_ext_dfn_id
      		  ,p_ext_prefix          => p_new_extract_name
      		  ,p_business_group_id   => p_business_group_id
      		  );
  END LOOP; -- 1

  -- Assign collection of formula ids to return variable
  p_formulas := t_Formulas;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

END copy_extract;

END ben_copy_extract;

/
