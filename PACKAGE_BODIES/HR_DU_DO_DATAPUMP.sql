--------------------------------------------------------
--  DDL for Package Body HR_DU_DO_DATAPUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DU_DO_DATAPUMP" AS
/* $Header: perdudp.pkb 115.29 2002/11/28 15:25:47 apholt noship $ */

-- ------------------------- STORE_COLUMN_HEADINGS ------------------------
-- Description: This procedure extracts the column headings for the given
-- line and caches them into a table to save on the number of select
-- statements used in the code.
--
--  Input Parameters
--          p_line_id    - Identifies the UPLOAD_LINE to be used
-- ------------------------------------------------------------------------
PROCEDURE STORE_COLUMN_HEADINGS (p_line_id IN NUMBER)
IS

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_do_datapump.
                                       store_column_headings', 5);
  hr_du_utility.message('PARA', '(p_line_id - ' || p_line_id || ')'
                                , 10);

  hr_du_utility.message('INFO','Select Statement Start ' , 15);

        SELECT
 	  PVAL001, PVAL002, PVAL003,  PVAL004 , PVAL005 , PVAL006,
 	  PVAL007, PVAL008, PVAL009,  PVAL010 , PVAL011, PVAL012,
 	  PVAL013, PVAL014, PVAL015,  PVAL016 , PVAL017,  PVAL018,
 	  PVAL019,  PVAL020,  PVAL021, PVAL022,  PVAL023,  PVAL024,
 	  PVAL025,  PVAL026,  PVAL027, PVAL028,  PVAL029,  PVAL030,
 	  PVAL031,  PVAL032,  PVAL033, PVAL034,  PVAL035,  PVAL036,
 	  PVAL037,  PVAL038,  PVAL039, PVAL040,  PVAL041,  PVAL042,
 	  PVAL043,  PVAL044,  PVAL045, PVAL046,  PVAL047,  PVAL048,
 	  PVAL049,  PVAL050,  PVAL051, PVAL052,  PVAL053,  PVAL054,
 	  PVAL055,  PVAL056,  PVAL057, PVAL058,  PVAL059,  PVAL060,
 	  PVAL061,  PVAL062,  PVAL063, PVAL064,  PVAL065,  PVAL066,
 	  PVAL067,  PVAL068,  PVAL069, PVAL070,  PVAL071,  PVAL072,
 	  PVAL073,  PVAL074,  PVAL075, PVAL076,  PVAL077,  PVAL078,
 	  PVAL079,  PVAL080,  PVAL081, PVAL082,  PVAL083,  PVAL084,
 	  PVAL085,  PVAL086,  PVAL087, PVAL088,  PVAL089,  PVAL090,
 	  PVAL091,  PVAL092,  PVAL093, PVAL094,  PVAL095,  PVAL096,
 	  PVAL097,  PVAL098,  PVAL099, PVAL100, PVAL101, PVAL102,
 	  PVAL103, PVAL104, PVAL105,PVAL106, PVAL107, PVAL108,
 	  PVAL109, PVAL110, PVAL111,PVAL112, PVAL113, PVAL114,
 	  PVAL115, PVAL116, PVAL117,PVAL118, PVAL119, PVAL120,
 	  PVAL121, PVAL122, PVAL123,PVAL124, PVAL125, PVAL126,
 	  PVAL127, PVAL128, PVAL129,PVAL130, PVAL131, PVAL132,
 	  PVAL133, PVAL134, PVAL135,PVAL136, PVAL137, PVAL138,
 	  PVAL139, PVAL140, PVAL141,PVAL142, PVAL143, PVAL144,
 	  PVAL145, PVAL146, PVAL147,PVAL148, PVAL149, PVAL150,
 	  PVAL151, PVAL152, PVAL153,PVAL154, PVAL155, PVAL156,
 	  PVAL157, PVAL158, PVAL159,PVAL160, PVAL161, PVAL162,
 	  PVAL163, PVAL164, PVAL165,PVAL166, PVAL167, PVAL168,
 	  PVAL169, PVAL170, PVAL171,PVAL172, PVAL173, PVAL174,
 	  PVAL175, PVAL176, PVAL177,PVAL178, PVAL179, PVAL180,
 	  PVAL181, PVAL182, PVAL183,PVAL184, PVAL185, PVAL186,
 	  PVAL187, PVAL188, PVAL189,PVAL190, PVAL191, PVAL192,
 	  PVAL193, PVAL194, PVAL195,PVAL196, PVAL197, PVAL198,
 	  PVAL199, PVAL200, PVAL201,PVAL202, PVAL203, PVAL204,
 	  PVAL205, PVAL206, PVAL207,PVAL208, PVAL209, PVAL210,
 	  PVAL211, PVAL212, PVAL213,PVAL214, PVAL215, PVAL216,
  	  PVAL217, PVAL218, PVAL219,PVAL220, PVAL221, PVAL222,
 	  PVAL223, PVAL224, PVAL225,PVAL226, PVAL227, PVAL228,
 	  PVAL229, PVAL230
        INTO
 	  g_column_headings(1), g_column_headings(2), g_column_headings(3),
     	  g_column_headings(4), g_column_headings(5), g_column_headings(6),
 	  g_column_headings(7), g_column_headings(8), g_column_headings(9),
 	  g_column_headings(10), g_column_headings(11), g_column_headings(12),
 	  g_column_headings(13), g_column_headings(14), g_column_headings(15),
 	  g_column_headings(16), g_column_headings(17), g_column_headings(18),
 	  g_column_headings(19), g_column_headings(20), g_column_headings(21),
 	  g_column_headings(22), g_column_headings(23), g_column_headings(24),
 	  g_column_headings(25), g_column_headings(26), g_column_headings(27),
 	  g_column_headings(28), g_column_headings(29), g_column_headings(30),
 	  g_column_headings(31), g_column_headings(32), g_column_headings(33),
 	  g_column_headings(34), g_column_headings(35), g_column_headings(36),
 	  g_column_headings(37), g_column_headings(38), g_column_headings(39),
 	  g_column_headings(40), g_column_headings(41), g_column_headings(42),
 	  g_column_headings(43), g_column_headings(44), g_column_headings(45),
 	  g_column_headings(46), g_column_headings(47), g_column_headings(48),
 	  g_column_headings(49), g_column_headings(50), g_column_headings(51),
 	  g_column_headings(52), g_column_headings(53), g_column_headings(54),
 	  g_column_headings(55), g_column_headings(56), g_column_headings(57),
 	  g_column_headings(58), g_column_headings(59), g_column_headings(60),
 	  g_column_headings(61), g_column_headings(62), g_column_headings(63),
 	  g_column_headings(64), g_column_headings(65), g_column_headings(66),
 	  g_column_headings(67), g_column_headings(68), g_column_headings(69),
 	  g_column_headings(70), g_column_headings(71), g_column_headings(72),
 	  g_column_headings(73), g_column_headings(74), g_column_headings(75),
 	  g_column_headings(76), g_column_headings(77), g_column_headings(78),
 	  g_column_headings(79), g_column_headings(80), g_column_headings(81),
 	  g_column_headings(82), g_column_headings(83), g_column_headings(84),
 	  g_column_headings(85), g_column_headings(86), g_column_headings(87),
 	  g_column_headings(88), g_column_headings(89), g_column_headings(90),
 	  g_column_headings(91), g_column_headings(92), g_column_headings(93),
 	  g_column_headings(94), g_column_headings(95), g_column_headings(96),
 	  g_column_headings(97), g_column_headings(98), g_column_headings(99),
 	  g_column_headings(100),g_column_headings(101),g_column_headings(102),
 	  g_column_headings(103),g_column_headings(104),g_column_headings(105),
 	  g_column_headings(106),g_column_headings(107),g_column_headings(108),
 	  g_column_headings(109),g_column_headings(110),g_column_headings(111),
 	  g_column_headings(112),g_column_headings(113),g_column_headings(114),
 	  g_column_headings(115),g_column_headings(116),g_column_headings(117),
 	  g_column_headings(118),g_column_headings(119),g_column_headings(120),
 	  g_column_headings(121),g_column_headings(122),g_column_headings(123),
 	  g_column_headings(124),g_column_headings(125),g_column_headings(126),
 	  g_column_headings(127),g_column_headings(128),g_column_headings(129),
 	  g_column_headings(130),g_column_headings(131),g_column_headings(132),
 	  g_column_headings(133),g_column_headings(134),g_column_headings(135),
 	  g_column_headings(136),g_column_headings(137),g_column_headings(138),
 	  g_column_headings(139),g_column_headings(140),g_column_headings(141),
 	  g_column_headings(142),g_column_headings(143),g_column_headings(144),
 	  g_column_headings(145),g_column_headings(146),g_column_headings(147),
 	  g_column_headings(148),g_column_headings(149),g_column_headings(150),
 	  g_column_headings(151),g_column_headings(152),g_column_headings(153),
 	  g_column_headings(154),g_column_headings(155),g_column_headings(156),
 	  g_column_headings(157),g_column_headings(158),g_column_headings(159),
 	  g_column_headings(160),g_column_headings(161),g_column_headings(162),
 	  g_column_headings(163),g_column_headings(164),g_column_headings(165),
 	  g_column_headings(166),g_column_headings(167),g_column_headings(168),
 	  g_column_headings(169),g_column_headings(170),g_column_headings(171),
 	  g_column_headings(172),g_column_headings(173),g_column_headings(174),
 	  g_column_headings(175),g_column_headings(176),g_column_headings(177),
 	  g_column_headings(178),g_column_headings(179),g_column_headings(180),
 	  g_column_headings(181),g_column_headings(182),g_column_headings(183),
 	  g_column_headings(184),g_column_headings(185),g_column_headings(186),
 	  g_column_headings(187),g_column_headings(188),g_column_headings(189),
 	  g_column_headings(190),g_column_headings(191),g_column_headings(192),
 	  g_column_headings(193),g_column_headings(194),g_column_headings(195),
 	  g_column_headings(196),g_column_headings(197),g_column_headings(198),
 	  g_column_headings(199),g_column_headings(200),g_column_headings(201),
 	  g_column_headings(202),g_column_headings(203),g_column_headings(204),
 	  g_column_headings(205),g_column_headings(206),g_column_headings(207),
 	  g_column_headings(208),g_column_headings(209),g_column_headings(210),
 	  g_column_headings(211),g_column_headings(212),g_column_headings(213),
 	  g_column_headings(214),g_column_headings(215),g_column_headings(216),
 	  g_column_headings(217),g_column_headings(218),g_column_headings(219),
 	  g_column_headings(220),g_column_headings(221),g_column_headings(222),
 	  g_column_headings(223),g_column_headings(224),g_column_headings(225),
 	  g_column_headings(226),g_column_headings(227),g_column_headings(228),
 	  g_column_headings(229),g_column_headings(230)
    FROM HR_DU_UPLOAD_LINES
    WHERE UPLOAD_LINE_ID = p_line_id;

  hr_du_utility.message('INFO','Select Statement Ends ' , 20);

--
  hr_du_utility.message('ROUT','exit:hr_du_do_datapump.' ||
                                   ' store_column_headings', 25);
--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_do_datapump.
                                             store_column_headings',
                       '(none)', 'R');
    RAISE;
--
END STORE_COLUMN_HEADINGS;



-- ---------------------- FIND_USER_KEY_FROM_MAPPINGS ----------------------
-- Description: Simply uses a Cursor to retrieve any column from
-- COLUMN_MPAPPINGS that has a mapping type of U. For example the
-- mapped_to_name retrieved for the CREATE_US_EMPLOYEE would be i.e.
-- 'p_employee_user_key'.
--
-- ------------------------------------------------------------------------
FUNCTION FIND_USER_KEY_FROM_MAPPINGS(p_api_module_id IN NUMBER)
				 RETURN VARCHAR2
IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_user_key			VARCHAR2(2000);

CURSOR csr_user_key IS
  SELECT mapped_to_name
  FROM   hr_du_column_mappings
  WHERE  API_MODULE_ID = p_api_module_id
  AND    MAPPING_TYPE = 'U';

BEGIN
--
  hr_du_utility.message('ROUT',
         'entry:hr_du_do_datapump.find_user_key_from_mappings', 5);
  hr_du_utility.message('PARA', '(p_api_module_id - ' ||
         p_api_module_id || ')' , 10);
--

  OPEN csr_user_key;
  --
    FETCH  csr_user_key INTO l_user_key;
    IF csr_user_key%NOTFOUND THEN
      l_fatal_error_message := ' Unable to retrieve the user key';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE  csr_user_key;

--
  hr_du_utility.message('ROUT',
            'exit:hr_du_do_datapump.find_user_key_from_mappings', 15);
  hr_du_utility.message('PARA', '(l_user_key - ' || l_user_key || ')' , 20);
--

  RETURN l_user_key;

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.
               find_user_key_from_mappings',l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
       'hr_du_do_datapump.find_user_key_from_mappings','(none)', 'R');
    RAISE;
--
END FIND_USER_KEY_FROM_MAPPINGS;



-- ------------------------ API_ID_TO_PROCESS_ORDER -----------------------
-- Description: Cursor is run to work out the Process order of a file from
-- it's given API_module_Id.
--
-- ------------------------------------------------------------------------
FUNCTION API_ID_TO_PROCESS_ORDER(p_api_module_id IN NUMBER,
                                 p_upload_id IN NUMBER)
				 RETURN NUMBER
IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_process_order		NUMBER;


CURSOR csr_process_order IS
  SELECT des2.value
  FROM hr_du_descriptors des1,
       hr_du_descriptors des2,
       hr_api_modules api
  WHERE des1.upload_id = p_upload_id
    and upper(des1.descriptor) = 'API'
    and upper(des2.descriptor) = 'PROCESS ORDER'
    and des2.descriptor_type = 'D'
    and des1.upload_header_id = des2.upload_header_id
    and api.api_module_id = p_api_module_id
    and upper(des1.value) = api.module_name;

BEGIN
--
  hr_du_utility.message('ROUT',
            'entry:hr_du_do_datapump.api_id_to_process_order', 5);
  hr_du_utility.message('PARA', '(p_api_module_id - ' || p_api_module_id ||
			')(p_upload_id - ' || p_upload_id || ')'
                        , 10);
--

  OPEN csr_process_order;
  --
    FETCH csr_process_order INTO l_process_order;
    IF csr_process_order%NOTFOUND THEN
      l_fatal_error_message := ' Unable to retrieve the process order';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_process_order;

--
  hr_du_utility.message('ROUT',
            'exit:hr_du_do_datapump.api_id_to_process_order', 15);
  hr_du_utility.message('PARA', '(l_process_order - ' || l_process_order
                                  || ')' , 20);
--

  RETURN l_process_order;

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.api_id_to_process_order'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
       'hr_du_do_datapump.api_id_to_process_order','(none)', 'R');
    RAISE;
--
END API_ID_TO_PROCESS_ORDER;


-- ----------------------- ANY_EXTRA_REFERENCES -------------------------
-- Description: Special case to catch those API's that have user keys
-- which need to be complete for the API and aren't mentioned up to this
-- point. Such an example is p_assignment_user_key in the person module.
--
--  Input Parameters
--
--     p_user_key   -  This is the calling API's p_user_key. To be matched
--                     to API's in the column_mappings's column_name
--
--    p_api_module_id   -  The specific api_module id.
--
--
--  Output Parameters
--
--   p_number_of_keys   - The number of extra references encountered
--
--   l_extra_user_keys  - String with the p_foreign_user_keys joined together
--                        separated by commas
--
-- ------------------------------------------------------------------------
FUNCTION ANY_EXTRA_REFERENCES(p_user_key IN VARCHAR2,
                              p_api_module_id IN NUMBER,
                              p_number_of_keys OUT NOCOPY INTEGER)
                              RETURN VARCHAR2
IS

CURSOR csr_references IS
  SELECT mapped_to_name
    FROM hr_du_column_mappings
    WHERE api_module_id = p_api_module_id
    AND   mapping_type = 'D'
    AND   column_name = p_user_key;

  l_extra_user_keys	VARCHAR2(2000)	:= NULL;
  l_extra_name		VARCHAR2(2000);
  l_length		NUMBER;
  l_string_length 	NUMBER;

BEGIN
--
  hr_du_utility.message('ROUT',
            'entry:hr_du_do_datapump.any_extra_references', 5);
  hr_du_utility.message('PARA', '(p_user_key - ' || p_user_key ||
			')(p_api_module_id - ' || p_api_module_id ||
			')(p_number_of_keys - ' || p_number_of_keys || ')'
                        , 10);
--
  p_number_of_keys := 0;

  OPEN csr_references;
  --
    FETCH csr_references INTO l_extra_name;
    IF csr_references%FOUND THEN
      l_extra_user_keys := l_extra_user_keys || l_extra_name || ',' ;
      p_number_of_keys := p_number_of_keys + 1;
    END IF;
  --
  CLOSE csr_references;

  IF p_number_of_keys > 0 THEN
    --removes the last ',' at the end of the string
    l_length := LENGTHB(',');
    l_string_length := LENGTHB(l_extra_user_keys);
    l_extra_user_keys := SUBSTRB(l_extra_user_keys,1,
                         (l_string_length - l_length));
  END IF;

--
  hr_du_utility.message('ROUT',
            'exit:hr_du_do_datapump.any_extra_references', 15);
  hr_du_utility.message('PARA', '(l_extra_user_keys - ' || l_extra_user_keys
                                  || ')' , 20);
--

  RETURN l_extra_user_keys;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
       'hr_du_do_datapump.any_extra_references','(none)', 'R');
    RAISE;
--
END ANY_EXTRA_REFERENCES;


-- ----------------------- GENERAL_REFERENCING_COLUMN ----------------------
-- Description: Checks to see whether the column name passed is a
-- referencing or a datapump column, depending on the variables passed
--
--  Input Parameters
--
--        p_pval_field        - The name of which column the information
--                              should be in.
--
--        p_api_module_id     - api_module id relating to HR_API_MODULES
--
--        p_mapping_type      - The output target i.e. 'D' (datapump) or
--                              'R' (referencing)
--
--  Output Parameters
--
--         l_mapped_name      - The name of the field MAPPED_TO_NAME in
--                              HR_DU_COLUMN_MAPPINGS if a match is found.
-- ------------------------------------------------------------------------
FUNCTION GENERAL_REFERENCING_COLUMN(p_pval_field IN VARCHAR2,
                                    p_api_module_id IN NUMBER,
                                    p_mapping_type IN VARCHAR2)
                                    RETURN VARCHAR2
IS

  l_mapped_name		VARCHAR2(30);

CURSOR csr_ref_col IS
  SELECT mapped_to_name
    FROM hr_du_column_mappings
    WHERE api_module_id = p_api_module_id
    AND   mapping_type = p_mapping_type
    AND   column_name = p_pval_field
    AND   PARENT_api_module_ID IS NULL
    AND   PARENT_TABLE IS NULL;

BEGIN
--
  hr_du_utility.message('PARA', '(p_pval_field- ' || p_pval_field ||
			')(p_api_module_id - ' || p_api_module_id ||
			')(p_mapping_type - ' || p_mapping_type || ')'
                        , 5);
--
  OPEN csr_ref_col;
  --
    FETCH csr_ref_col INTO l_mapped_name;
    IF csr_ref_col%NOTFOUND THEN
      l_mapped_name := null;
    END IF;
  --
  CLOSE csr_ref_col;
--
  hr_du_utility.message('PARA', '(l_mapped_name - ' || l_mapped_name || ')'
                        , 10);
--

  RETURN l_mapped_name;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
       'hr_du_do_datapump.general_referencing_column','(none)', 'R');
    RAISE;
--
END GENERAL_REFERENCING_COLUMN;


-- ----------------------------- SET_STATUS --------------------------------
-- Description: Sets all the lines that will be read during the execution
-- of this package.
--
--  Input Parameters
--         p_upload_id - Link to the HR_DU_UPLOADS table that will allow all
--		         the relevant HR_DU_UPLOAD_LINES to be identified
-- -------------------------------------------------------------------------
PROCEDURE SET_STATUS(p_upload_id IN NUMBER) IS

BEGIN

--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.set_status', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')', 10);
--

  UPDATE hr_du_upload_lines
  SET status = 'NS'
  WHERE UPLOAD_HEADER_ID IN (SELECT upload_header_id
                             FROM hr_du_upload_headers
                             WHERE upload_id = p_upload_id)
  AND (REFERENCE_TYPE = 'CP' OR LINE_TYPE = 'C');
  COMMIT;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.set_status', 15);
--

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.set_status'
                       ,'(none)', 'R');
    RAISE;
--
END SET_STATUS;


-- -------------------- RETURN_CREATED_USER_KEY ---------------------------
-- Description: This is called from HR_DU_ENTITIES and the user key is
-- passed containing its PVAL's and the strings. This function makes up the
-- appropriate for the user key for the particular HR_DU_UPLOAD_LINE
--
--  Input Parameters
--         p_api_module_id  - ID identifying the correct api_module
--
--         p_column_id  - The ID of the column that the function will be
--                        working on.
--
--         p_upload_id  - Identifies the correct HR_DU_UPLOAD
--
--  Output Parameters
--        p_user_key    - Returns the column name from HR_DU_COLUMN_MAPPINGS
--                        to what the user key is mapped to
--
--   l_actual_user_key  - This is the user key that uniquely identifies a
--                        record
-- ------------------------------------------------------------------------
FUNCTION RETURN_CREATED_USER_KEY(p_api_module_id IN NUMBER,
                                 p_column_id IN NUMBER,
                                 p_upload_id IN NUMBER,
                                 p_user_key OUT NOCOPY VARCHAR2)
                                 RETURN VARCHAR2 IS


  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_table_size  	NUMBER;
  l_array_pos		NUMBER		:= null;
  l_dynamic_string	VARCHAR2(2000);
  l_upload_line_id	NUMBER;
  l_number_keys		NUMBER;
  l_field_value		VARCHAR2(2000);
  l_actual_user_key	VARCHAR2(2000)	:= null;
  l_length 		NUMBER;
  l_string_length	NUMBER;
  l_single_key		VARCHAR2(2000);
  l_position		NUMBER;
  l_user_key_table_size NUMBER;
  l_found_id_value	BOOLEAN;


 CURSOR csr_upload_line_id IS
   SELECT line.UPLOAD_LINE_ID
   FROM   hr_du_upload_headers head,
          hr_du_upload_lines   line
   WHERE  head.upload_id = p_upload_id
    AND    head.api_module_id = p_api_module_id
    AND    line.upload_header_id = head.upload_header_id
    AND    line.PVAL001 = to_char(p_column_id);

BEGIN
--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.return_created_user_key', 5);
  hr_du_utility.message('PARA', '(p_api_module_id - ' || p_api_module_id ||
 				')(p_column_id - ' || p_column_id ||
				')(p_upload_id - ' || p_upload_id || ')' ,
                                10);
--
  l_table_size := g_values_table.count;
  FOR i IN 1..l_table_size LOOP
    IF g_values_table(i).r_api_id = p_api_module_id THEN
      l_array_pos := i;
      EXIT;
    END IF;
  END LOOP;

  IF l_array_pos IS NULL THEN
    l_fatal_error_message := 'Unable to match api_module_ID to PL/SQL ' ||
                             'table values';
    RAISE e_fatal_error;
  END IF;


  --Returns the table size
  l_user_key_table_size := g_user_key_table.count;
  l_found_id_value := FALSE;

  FOR k IN 1..l_user_key_table_size LOOP
    --
    IF (g_user_key_table(k).r_api_module_id = p_api_module_id) AND
       (g_user_key_table(k).r_column_id = p_column_id) THEN
      p_user_key := g_user_key_table(k).r_user_key;
      l_actual_user_key := g_user_key_table(k).r_actual_user_key;
      l_found_id_value := TRUE;
      EXIT;
    END IF;
  --
  END LOOP;

  IF l_found_id_value = FALSE THEN
  --
    --Selects the line id for a given line who has the matching ID value which
    --is stored in the position of the id column for the particular api_module
    OPEN csr_upload_line_id;
    --
      FETCH csr_upload_line_id INTO l_upload_line_id;
      IF csr_upload_line_id%NOTFOUND THEN
        l_fatal_error_message := ' Unable to fine ID ' || p_column_id ||
          ' in API ' || p_api_module_id ||
          '. Referencing column in other file has this invalid reference';
        RAISE e_fatal_error;
      END IF;
    --
    CLOSE csr_upload_line_id;

    hr_du_utility.message('INFO', 'l_upload_line_id : ' ||
                                   l_upload_line_id , 20);

    -- now work out the size of the user key separated by : loop around
    -- getting it and then glue them on to a string

    hr_du_di_insert.g_current_delimiter   := ':';

    hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                    g_values_table(l_array_pos).r_user_key_pval);

    l_number_keys := hr_du_di_insert.WORDS_ON_LINE(
                     g_values_table(l_array_pos).r_user_key_pval);

    IF g_values_table(l_array_pos).r_user_key_pval IS NOT NULL THEN
    --
      FOR j IN 1..l_number_keys LOOP

        l_single_key := hr_du_di_insert.Return_Word(
                         g_values_table(l_array_pos).r_user_key_pval, j);

        l_position := INSTRB( l_single_key, '%');

        IF l_position > 0 THEN
          --adds user stated strings to the user_key
          hr_du_di_insert.g_current_delimiter   := '%';

          hr_du_di_insert.g_delimiter_count := hr_du_di_insert.
                                  Num_Delimiters(l_single_key);
          l_single_key := hr_du_di_insert.Return_Word(l_single_key, 2);
          l_actual_user_key := l_actual_user_key || ':' || '''' ||
                               l_single_key || '''';
        ELSE
          --adds column values to the user_key

          l_field_value := hr_du_dp_pc_conversion.return_field_value
                           ('HR_DU_UPLOAD_LINES', l_upload_line_id,
                            'upload_line_id', l_single_key);

          l_actual_user_key := l_actual_user_key || ':' || l_field_value;
        END IF;
      END LOOP;

      l_length := LENGTHB(':');
      l_string_length := LENGTHB(l_actual_user_key);
      l_actual_user_key := SUBSTRB(l_actual_user_key, l_length + 1);

      --this value is returned in OUT parameters
      p_user_key := FIND_USER_KEY_FROM_MAPPINGS(g_values_table(l_array_pos).
                                              r_api_id);
    --
    END IF;

    -- the user key can be a maximum of 240 characters long
    IF (length(l_actual_user_key) > 240) THEN
      l_fatal_error_message := 'The generated user key, ' || l_actual_user_key
                               || ', is over 240 characters long, which is the'
                               || ' maximum size for Datapump.';
      RAISE e_fatal_error;
    END IF;

    l_user_key_table_size := g_user_key_table.count;
    --Add the information to the table
    g_user_key_table(l_user_key_table_size + 1).r_api_module_id :=
                                                  p_api_module_id;
    g_user_key_table(l_user_key_table_size + 1).r_column_id :=
                                                      p_column_id;
    g_user_key_table(l_user_key_table_size + 1).r_user_key :=
                                                       p_user_key;
    g_user_key_table(l_user_key_table_size + 1).r_actual_user_key :=
                                                l_actual_user_key;
  --
  END IF;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.return_created_user_key', 15);
  hr_du_utility.message('PARA', '(l_actual_user_key - ' || l_actual_user_key
                        || ')' , 20);
--

  RETURN l_actual_user_key;

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.return_created_user_key'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.return_created_user_key'
                       ,'(none)', 'R');
    RAISE;
--
END RETURN_CREATED_USER_KEY;


-- -------------------- RETURN_CREATED_USER_KEY_2 --------------------------
-- Description: This is called from HR_DU_ENTITIES. The way that it differs
-- from RETURN_CREATED_USER_KEY is that it's called by an upload_line
-- to work out its own user key and not a referencing user key.
--
--  Input Parameters
--     p_api_module_id  - ID identifying the correct api_module
--
--     p_upload_line_id - Identifies the UPLOAD_LINE_ID
--
--  Output Parameters
--        p_user_key    - Returns the column name from HR_DU_COLUMN_MAPPINGS
--                        to what the user key is mapped to
--
--   l_actual_user_key  - This is the user key that uniquely identifies a
--                        record
-- ------------------------------------------------------------------------
FUNCTION RETURN_CREATED_USER_KEY_2(
                                 p_column_id IN NUMBER,
                                 p_api_module_id IN NUMBER,
 				 p_upload_line_id IN NUMBER,
                                 p_user_key OUT NOCOPY VARCHAR2)
                                 RETURN VARCHAR2 IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_table_size  	NUMBER;
  l_array_pos		NUMBER		:= null;
  l_number_keys		NUMBER;
  l_field_value		VARCHAR2(2000);
  l_actual_user_key	VARCHAR2(2000)	:= null;
  l_length 		NUMBER;
  l_string_length	NUMBER;
  l_single_key		VARCHAR2(2000);
  l_position		NUMBER;
  l_user_key_table_size NUMBER;

BEGIN

--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.return_created_user_key_2', 5);
  hr_du_utility.message('PARA', '(p_column_id - ' || p_column_id ||
 				')(p_api_module_id - ' || p_api_module_id ||
 				')(p_upload_line_id - ' || p_upload_line_id
				||  ')' , 10);
--

  l_table_size := g_values_table.count;
  FOR i IN 1..l_table_size LOOP
    IF g_values_table(i).r_api_id = p_api_module_id THEN
      l_array_pos := i;
      EXIT;
    END IF;
  END LOOP;

  IF l_array_pos IS NULL THEN
    l_fatal_error_message := 'Unable to match api_module_ID to PL/SQL ' ||
                             'table values';
    RAISE e_fatal_error;
  END IF;

  -- now work out the size of the user key separated by : loop around
  -- getting it and then glue them on to a string

  hr_du_di_insert.g_current_delimiter   := ':';

  hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                     g_values_table(l_array_pos).r_user_key_pval);

  l_number_keys := hr_du_di_insert.WORDS_ON_LINE(
                   g_values_table(l_array_pos).r_user_key_pval);

  IF g_values_table(l_array_pos).r_user_key_pval IS NOT NULL THEN
  --
    FOR j IN 1..l_number_keys LOOP

       l_single_key := hr_du_di_insert.Return_Word(
                      g_values_table(l_array_pos).r_user_key_pval, j);

      l_position := INSTRB( l_single_key, '%');

      IF l_position > 0 THEN
        --adds user stated strings to the user_key
        hr_du_di_insert.g_current_delimiter   := '%';

        hr_du_di_insert.g_delimiter_count := hr_du_di_insert.
                                 Num_Delimiters(l_single_key);

        l_single_key := hr_du_di_insert.Return_Word(l_single_key, 2);
        l_actual_user_key := l_actual_user_key || ':' || '''' ||
                             l_single_key || '''';
      ELSE
        --adds column values to the user_key

        l_field_value := hr_du_dp_pc_conversion.RETURN_FIELD_VALUE
                         ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                          'upload_line_id', l_single_key);

        l_actual_user_key := l_actual_user_key || ':' || l_field_value;
      END IF;
    END LOOP;

    l_length := LENGTHB(':');
    l_string_length := LENGTHB(l_actual_user_key);
    l_actual_user_key := SUBSTRB(l_actual_user_key, l_length + 1);

    --this value is returned in OUT parameters
    p_user_key := FIND_USER_KEY_FROM_MAPPINGS(g_values_table(l_array_pos).
                                              r_api_id);
  --
  END IF;

-- the user key can be a maximum of 240 characters long
  IF (length(l_actual_user_key) > 240) THEN
    l_fatal_error_message := 'The generated user key, ' || l_actual_user_key
                             || ', is over 240 characters long, which is the'
                             || ' maximum size for Datapump.';
    RAISE e_fatal_error;
  END IF;

    l_user_key_table_size := g_user_key_table.count;

    --Add the information to the table
    g_user_key_table(l_user_key_table_size + 1).r_api_module_id := p_api_module_id;
    g_user_key_table(l_user_key_table_size + 1).r_column_id := p_column_id;
    g_user_key_table(l_user_key_table_size + 1).r_user_key := p_user_key;
    g_user_key_table(l_user_key_table_size + 1).r_actual_user_key := l_actual_user_key;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.return_created_user_key_2', 15);
  hr_du_utility.message('PARA', '(l_actual_user_key - ' || l_actual_user_key
                        || ')' , 20);
--

  RETURN l_actual_user_key;

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.return_created_user_key_2'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.return_created_user_key_2'
                       ,'(none)', 'R');
    RAISE;
--
END RETURN_CREATED_USER_KEY_2;


-- ------------------------- RETURN_PVAL ---------------------------------
-- Description: The function takes a mapped_to_name and tires to match it
-- to an entry in the R_INSERT_STRING row of the PL/SQL table. If the match
-- is found the the corresponding entry in the R_PVAL_STRING is returned.
--
--  Input Parameters
--        p_mapped_name   - The name your looking for in R_INSERT_STRING
--
--         p_table_pos    - The numerical position in the PL/SQL table
--
--  Output Parameters
--         l_pval         - The corresponding PVAL*** in the R_PVAL_STRING
--
-- ------------------------------------------------------------------------
FUNCTION RETURN_PVAL(p_mapped_name IN VARCHAR2,
                     p_table_pos IN NUMBER)
                     RETURN VARCHAR2 IS

  l_number_names		NUMBER;
  l_pval 			VARCHAR2(50)	:= null;
  l_single_name			VARCHAR2(50);

BEGIN
--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.return_pval', 5);
  hr_du_utility.message('PARA', '(p_mapped_name - ' || p_mapped_name ||
				')(p_table_pos - ' || p_table_pos || ')' ,
                                10);
--


 hr_du_di_insert.g_current_delimiter   := ',';

  hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                      g_values_table(p_table_pos).r_insert_string);

  l_number_names := hr_du_di_insert.WORDS_ON_LINE(
                    g_values_table(p_table_pos).r_insert_string);

  FOR j IN 1..l_number_names LOOP
  --
    hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                       g_values_table(p_table_pos).r_insert_string);

    l_single_name := hr_du_di_insert.Return_Word(
                     g_values_table(p_table_pos).r_insert_string, j);

    IF l_single_name = p_mapped_name THEN
    --
      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                      g_values_table(p_table_pos).r_PVAL_string);

      l_pval:= hr_du_di_insert.Return_Word(
               g_values_table(p_table_pos).r_PVAL_string, j);
      EXIT;
    --
    END IF;
  --
  END LOOP;
--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.return_pval', 30);
  hr_du_utility.message('PARA', '(l_pval - ' || l_pval || ')' , 20);
--
  RETURN l_pval;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.return_pval'
                       ,'(none)', 'R');
    RAISE;
--
END RETURN_PVAL;


-- ---------------------- EXTRACT_BUSINESS_GROUP --------------------------
-- Description: Simple cursor that is run to find the business group which
-- is stored within the header file with the Descriptor name of
-- BUSINESS GROUP
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
FUNCTION EXTRACT_BUSINESS_GROUP(p_upload_id IN NUMBER)
                                RETURN VARCHAR2
IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_business_group		VARCHAR2(2000);

BEGIN

--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.extract_business_group', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')', 10);
--

  --Retrieve the business group for the appropriate HR_DU_UPLOADS
  BEGIN
    SELECT VALUE
    INTO l_business_group
    FROM HR_DU_DESCRIPTORS
    WHERE DESCRIPTOR = 'BUSINESS GROUP'
    AND upload_id = p_upload_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_fatal_error_message := 'Error occured while trying to retrieve the' ||
                               ' business group from HR_DU_UPLOADS with the'||
                               ' upload_id of : ' ||  p_upload_id ;
      RAISE e_fatal_error;
  END;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.extract_business_group', 15);
--

  RETURN l_business_group;

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.extract_business_group'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.extract_business_group'
                       ,'(none)', 'R');
    RAISE;
--
END EXTRACT_BUSINESS_GROUP;


-- ------------------------ EXTRACT_USER_KEY ------------------------------
-- Description: This function removes the user_key that is stored within
-- the HR_DU_DESCRIPTORS table. It is the exact string that was found in
-- the flat file in the descriptor block.
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
--        p_table_id    - Position in the PL/SQL table that the information
--			  is held about the API
-- ------------------------------------------------------------------------
FUNCTION EXTRACT_USER_KEY(p_upload_id IN NUMBER,
                          p_table_id IN NUMBER)
                          RETURN VARCHAR2 IS

  CURSOR csr_user_key IS
    SELECT descr.VALUE
    FROM HR_DU_DESCRIPTORS descr,
         HR_DU_UPLOAD_HEADERS head
    WHERE head.upload_id = p_upload_id
    AND   head.api_module_id = g_values_table(p_table_id).r_api_id
    AND   head.upload_header_id = descr.upload_header_id
    AND   descr.DESCRIPTOR = 'USER KEY';

  l_user_key			VARCHAR2(2000);

BEGIN

--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.extract_user_key', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id ||
				')(p_table_id - ' || p_table_id || ')' ,
                                10);
--
  OPEN csr_user_key;
  --
    FETCH csr_user_key INTO l_user_key;
    IF csr_user_key%NOTFOUND THEN
      l_user_key := null;
    END IF;
  --
  CLOSE csr_user_key;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.extract_user_key', 15);
  hr_du_utility.message('PARA', '(l_user_key - ' || l_user_key|| ')' , 20);
--

  RETURN l_user_key;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.extract_user_key'
                       ,'(none)', 'R');
    RAISE;
--
END EXTRACT_USER_KEY;



-- ------------------------- CREATE_USER_KEY_STRING -----------------------
-- Description: Stores the PVAL positions of the appropriate user key
-- columns stated by the user. Into a string R_USER_KEY_PVAL within the
-- PL/SQL table.
--
--  Input Parameters
--        p_upload_id   - Identifies this particular Upload over other
--			  simular ones.
--
--        p_table_size  - Size of the PL/SQL table
-- ------------------------------------------------------------------------
PROCEDURE CREATE_USER_KEY_STRING(p_upload_id IN VARCHAR2,
                                 p_table_size IN NUMBER) IS


  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_user_key		VARCHAR2(2000);
  l_number_keys		NUMBER;
  l_single_key		VARCHAR2(2000);
  l_mapped_name		VARCHAR2(50);
  l_key_pval		VARCHAR2(50);
  l_key_pval_string	VARCHAR2(2000)		:= null;
  l_length		NUMBER;
  l_length2		NUMBER;
  l_counter		NUMBER;
  l_position		NUMBER;
  l_temp		VARCHAR2(2000);
  l_api_id		NUMBER;
  l_referencing		VARCHAR2(200);
  l_upload_header_id	NUMBER;
  l_starting_bool	VARCHAR2(50);


--Cursor compares the user key word to HR_DU_COLUMN_MAPPINGS
--in the main header for all API's
  CURSOR csr_dollar_key IS
  SELECT des.VALUE
  FROM 	 hr_du_descriptors des,
         hr_du_uploads 	   uplo
  WHERE  uplo.upload_id = p_upload_id
    AND  uplo.upload_id = des.upload_id
    AND  des.upload_header_id IS NULL
    AND  upper(des.descriptor) = upper(l_single_key);

--Cursor compares the user key word to HR_DU_COLUMN_MAPPINGS
--in the specific API header
  CURSOR csr_dollar_key_api IS
  SELECT des.VALUE
  FROM 	 hr_du_descriptors     des,
         hr_du_upload_headers  head
  WHERE  head.api_module_id = l_api_id
    AND  head.upload_id = p_upload_id
    AND  head.upload_header_id = des.upload_header_id
    AND  upper(des.descriptor) = upper(l_single_key);

--Extracts the referencing type to checks for PC referencing
  CURSOR csr_referencing IS
  SELECT VALUE
  FROM   hr_du_descriptors
  WHERE  upload_header_id = l_upload_header_id
    AND  upper(descriptor) = 'REFERENCING';

--Extracts the referencing type to checks for a Starting point
  CURSOR csr_starting_point IS
  SELECT VALUE
  FROM   hr_du_descriptors
  WHERE  upload_header_id = l_upload_header_id
    AND  upper(descriptor) = 'STARTING POINT';


BEGIN

--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.create_user_key_string', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id ||
                 	')(p_table_size - ' || p_table_size || ')', 10);

--
  FOR l_counter IN 1..p_table_size LOOP
  --
    l_key_pval_string := null;

    --Extracts the user key defined by the user within the flat file
    l_user_key := EXTRACT_USER_KEY(p_upload_id, l_counter);
    hr_du_utility.message('INFO', 'API Module id : ' ||
                                   g_values_table(l_counter).r_api_id, 25);

    hr_du_di_insert.g_current_delimiter   := ':';

    hr_du_di_insert.g_delimiter_count := hr_du_di_insert.
                                         Num_Delimiters(l_user_key);
    l_number_keys := hr_du_di_insert.WORDS_ON_LINE(l_user_key);

    FOR j IN 1..l_number_keys LOOP
      l_key_pval := null;
      hr_du_di_insert.g_current_delimiter   := ':';

      l_single_key := hr_du_di_insert.Return_Word(l_user_key, j);

      l_position := INSTRB(l_single_key, '%');

      --No comments so compared to the column mappings
      IF l_position = 0 THEN
        l_mapped_name  := hr_du_dp_pc_conversion.general_referencing_column
                          (l_single_key, g_values_table(l_counter).
                                                      r_api_id,'D');
        IF l_mapped_name IS NULL THEN
          l_fatal_error_message := 'Error occured trying to map part of the '
                                 || 'user key : ' || l_single_key || ' ' ||
                                 'to a mapped_to_name in ' ||
                                 'HR_DU_COLUMN_MAPPINGS';
          RAISE e_fatal_error;
        END IF;

        l_key_pval := RETURN_PVAL(l_mapped_name, l_counter);

        IF l_key_pval IS NULL THEN
          l_fatal_error_message := 'Error occured trying to map part of the '
                                  || 'user key : ' || l_mapped_name || ' ' ||
                                  'to a PVAL column in HR_DU_UPLOAD_LINES';
          RAISE e_fatal_error;
        END IF;
        l_key_pval_string := l_key_pval_string || ':' || l_key_pval;

        --
      --Comments exist so it's a special case user key
      ELSE
        hr_du_di_insert.g_current_delimiter   := '%';
        hr_du_di_insert.g_delimiter_count :=
                        hr_du_di_insert.Num_Delimiters(l_single_key);
        l_single_key := hr_du_di_insert.Return_Word(l_single_key, 2);

       --Checks begin to see if there are any pointers to DESCRIPTORS
        l_position := INSTRB(l_single_key, '$');
        --
        IF l_position = 1 THEN
        --
          hr_du_di_insert.g_current_delimiter   := '$';
          hr_du_di_insert.g_delimiter_count :=
                          hr_du_di_insert.Num_Delimiters(l_single_key);

          l_single_key := hr_du_di_insert.Return_Word(l_single_key, 2);

          OPEN csr_dollar_key;
            FETCH csr_dollar_key INTO l_temp;
            IF csr_dollar_key%NOTFOUND THEN
            --
              l_api_id := g_values_table(l_counter).r_api_id;
              --this checks the specific headers for the API
              OPEN csr_dollar_key_api;
                FETCH csr_dollar_key_api INTO l_temp;
                IF csr_dollar_key_api%NOTFOUND THEN
                  l_fatal_error_message := 'User key $ is not a valid ' ||
                                           'descriptor';
                  RAISE e_fatal_error;
                ELSE
                  l_key_pval_string := l_key_pval_string || ':' || '''' ||
                                       l_temp|| '''';
                END IF;
              CLOSE csr_dollar_key_api;
            ELSE
                  l_key_pval_string := l_key_pval_string || ':' || '''' ||
                                       l_temp|| '''';
            END IF;
          --
          CLOSE csr_dollar_key;
          --
        ELSE
          IF upper(l_single_key) = 'NONE' THEN
            l_key_pval_string := null;
            EXIT;
          ELSE
            l_key_pval_string := l_key_pval_string || ':' || '''' ||
            l_single_key || '''';
          END IF;
        END IF;
      END IF;
    END LOOP;
    --
    l_upload_header_id := g_values_table(l_counter).r_upload_header_id;

    OPEN csr_referencing;
      FETCH csr_referencing INTO l_referencing;
      IF csr_referencing%NOTFOUND THEN
        l_fatal_error_message := 'Referencing descriptor no found';
        RAISE e_fatal_error;
      ELSIF upper(l_referencing) = 'PC' THEN
      --
        --Checks to see if the PC is the starting point if so there
	--is no reason to attach an id value to the user key.

        OPEN csr_starting_point;
          FETCH csr_starting_point INTO l_starting_bool;
          IF csr_starting_point%NOTFOUND THEN
	  --
  	    l_fatal_error_message := 'No starting point value has been ' ||
				     'found in the descriptors table. ';
            RAISE e_fatal_error;
	  ELSIF l_starting_bool = 'YES' THEN
	  --
            l_length := LENGTHB(':');
            l_length2 := LENGTHB(l_key_pval_string);
            l_key_pval_string := SUBSTRB(l_key_pval_string, l_length + 1);
	  ELSE
	    --The user key has has their ID attached to it to make it unique
            l_key_pval_string := 'PVAL001' || l_key_pval_string;
	  --
          END IF;
        CLOSE csr_starting_point;

      --
      ELSIF upper(l_referencing) = 'CP' THEN
      --
        l_length := LENGTHB(':');
        l_length2 := LENGTHB(l_key_pval_string);
        l_key_pval_string := SUBSTRB(l_key_pval_string, l_length + 1);
      --
      ELSE
        l_fatal_error_message := 'Referencing value is not of the correct ' ||
                                 'format PC / CP';
        RAISE e_fatal_error;
      END IF;
   CLOSE csr_referencing;

    --insert the string in to R_USER_KEY_PVAL
    hr_du_utility.message('INFO', 'l_key_pval_string : ' ||
                                   l_key_pval_string, 25);

    g_values_table(l_counter).r_user_key_pval := l_key_pval_string;
  --
  END LOOP;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.create_user_key_string', 30);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.create_user_key_string'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.create_user_key_string'
                       ,'(none)', 'R');
    RAISE;
--
END CREATE_USER_KEY_STRING;


-- ------------------------ CREATE_P_STRINGS ----------------------------
-- Description: Creates two strings, one of column names R_INSERT_STRING.
-- And the other of PVAL's R_PVAL_STRING, they are then placed into a
-- PL/SQL table in their appropriate row depending on their API
--
--  Input Parameters
--
--        p_api_module_id   -  Identifies the api_module
--
--        p_upload_id   -  Identifies the correct upload record
--
--        p_array_pos   -  The position within the global table
--
-- ------------------------------------------------------------------------
PROCEDURE CREATE_P_STRINGS(p_api_module_id IN NUMBER,
                           p_upload_id IN NUMBER,
                           p_array_pos IN NUMBER)
IS

--Returns the line_id for the column names in HR_DU_UPLOAD_LINES
  CURSOR csr_line_id IS
  SELECT line.UPLOAD_LINE_ID
    FROM hr_du_upload_headers head,
         hr_du_upload_lines   line
    WHERE head.upload_id = p_upload_id
    AND   head.api_module_id = p_api_module_id
    AND   line.upload_header_id = head.upload_header_id
    AND   line.LINE_TYPE = 'C';

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_pval_string		VARCHAR2(32767)		:= null ;
  l_pvalues_string	VARCHAR2(32767)		:= null ;
  l_current_pval	VARCHAR2(10);
  l_line_id		NUMBER(15);
  l_pval_field		VARCHAR2(50);
  l_mapped_name 	VARCHAR2(50);
  l_length		NUMBER;
  l_string_length 	NUMBER;

BEGIN
--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.create_p_strings', 5);
  hr_du_utility.message('PARA', '(p_api_module_id - ' || p_api_module_id ||
 				')(p_upload_id - ' || p_upload_id ||
				')(p_array_pos - ' || p_array_pos || ')' ,
                                10);
--
  OPEN csr_line_id;
    FETCH csr_line_id INTO l_line_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := 'No appropriate column title row exists in '||
                               'the HR_DU_UPLOAD_LINES for the api_module '||
                               'passed';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_line_id;

  STORE_COLUMN_HEADINGS (l_line_id);

  --loops around all the columns within the upload_line
  FOR i IN 1..230 LOOP
  --
    l_current_pval := LPAD(i,3,'0');
    l_current_pval := 'PVAL' || l_current_pval;
    l_pval_field   := g_column_headings(i);

    l_mapped_name  := general_referencing_column(l_pval_field,
                                                 p_api_module_id, 'D');

    IF l_mapped_name IS NOT NULL THEN
      l_pvalues_string := l_pvalues_string || l_mapped_name || ',' ;
      l_pval_string := l_pval_string || l_current_pval || ',' ;
    END IF;
  --
  END LOOP;

  l_length := LENGTHB(',');
  l_string_length := LENGTHB(l_pvalues_string);
  IF l_string_length > 0 THEN
    l_pvalues_string := SUBSTRB(l_pvalues_string,1,
                        (l_string_length - l_length));
    l_string_length := LENGTHB(l_pval_string);
    l_pval_string := SUBSTRB(l_pval_string,1,
                            (l_string_length - l_length));
  END IF;

  g_values_table(p_array_pos).r_insert_string   := l_pvalues_string;
  g_values_table(p_array_pos).r_PVAL_string     := l_pval_string;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.create_p_strings', 15);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.create_p_strings'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.create_p_strings'
                       ,'(none)', 'R');
    RAISE;
--
END CREATE_P_STRINGS;



-- ------------------------- PRODUCE_TABLE ---------------------------------
-- Description: The PL/SQL table is first created here and fill with the
-- initial values of api_module_ids and their corresponding upload_header_ids
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
PROCEDURE PRODUCE_TABLE(p_upload_id IN NUMBER)
IS

CURSOR csr_apis IS
  SELECT api.api_module_id, des1.upload_header_id
  FROM   hr_du_descriptors des2,
         hr_api_modules api,
         hr_du_descriptors des1
  WHERE  des2.upload_id = p_upload_id
    AND  upper(des2.descriptor) = 'PROCESS ORDER'
    AND  des2.DESCRIPTOR_TYPE = 'D'
    AND  upper(api.module_name) = upper(des1.VALUE)
    AND  des1.DESCRIPTOR_TYPE = 'D'
    AND  des1.upload_header_id = des2.upload_header_id
    AND  upper(api.module_name) = upper(des1.VALUE)
  ORDER BY des2.value;

--exception to raise
  e_fatal_error 	EXCEPTION;
--string to input the error message
  l_fatal_error_message	VARCHAR2(2000);
  l_api_module_id     	NUMBER;
  l_counter		NUMBER		:=1;
  l_upload_header_id	NUMBER;

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_do_datapump.produce_table', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--
  OPEN csr_apis;
  LOOP
  --
    FETCH csr_apis INTO l_api_module_id, l_upload_header_id;
    EXIT WHEN csr_apis%NOTFOUND;
      g_values_table(l_counter).r_api_id     		:= l_api_module_id;
      g_values_table(l_counter).r_upload_header_id      := l_upload_header_id;
      create_p_strings(l_api_module_id, p_upload_id, l_counter);
      l_counter := l_counter + 1;
  --
  END LOOP;
  IF l_counter = 1 THEN
    l_fatal_error_message := 'No Data found to produce the API table ' ||
			     'with the upload_id provided ' ||
                             '( p_upload_id : ' || p_upload_id || ' )';
    RAISE e_fatal_error;
  END IF;
  CLOSE csr_apis;

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_do_datapump.produce_table', 15);
--

EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.produce_table'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_do_datapump.produce_table',
                       '(none)', 'R');
    RAISE;
--
END PRODUCE_TABLE;


-- ------------------------- REFERENCING_COLUMNS -----------------------
-- Description: Builds up the strings L_STRING_APIS, L_API_PVALS and
-- L_GENERIC_PVAL in the PL/SQL table. Loops around the column headings
-- for each API and checks them against the cursor constraints, if they
-- meet the requirements then they are placed into the strings.
--
--  Input Parameters
--
--        p_line_id    - Identifies the upload_line_id for the column
-- 			 heading line in question.
--
--    p_api_module_id  - Holds the id of the API to which the column
--			 heading is related to in the HR_API_MODULES table.
--
--        p_upload_id  - Holds the upload id to destinguish between
--                       entries in the HR_DU_UPLOADS table.
--
--        p_array_pos  - the array position in the PL/SQL table that is
--			 currently being used.
--
-- ------------------------------------------------------------------------
PROCEDURE REFERENCING_COLUMNS(p_line_id IN NUMBER,
                              p_api_module_id IN NUMBER,
                              p_upload_id IN NUMBER,
                              p_array_pos IN NUMBER)
 IS

  l_string_apis			VARCHAR2(100);
  l_api_PVALS			VARCHAR2(300);
  l_generic_pval		VARCHAR2(30);
  l_current_pval		VARCHAR2(10);
  l_inner_pval  		VARCHAR2(10);
  l_pval_field			VARCHAR2(50);
  l_inner_field			VARCHAR2(50);
  l_parent_api_module_id	NUMBER;
  l_parent_table		VARCHAR2(35);
  l_length			NUMBER;
  l_string_length		NUMBER;

--Checks the column name to see if it has the properties of holding the
--calling api_module's id (parent's id) in that column.

CURSOR csr_parent_api_id IS
  SELECT parent_api_module_id
  FROM hr_du_column_mappings
  WHERE mapping_type = 'D'
  AND parent_api_module_id IS NOT null
  AND column_name = l_pval_field;

--Check to see if the column heading has the properties of a generic
--column. Due to some API's have two columns specifing both a column
--to store the api_module id and the line id.

CURSOR csr_parent_table_column IS
  SELECT parent_table
  FROM hr_du_column_mappings
  WHERE mapping_type = 'D'
  AND parent_table is not null
  AND column_name = l_pval_field;

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_do_datapump.referencing_columns',
                         5);
  hr_du_utility.message('PARA', '(p_line_id - ' || p_line_id ||
				')(p_api_module_id - ' || p_api_module_id ||
 				')(p_upload_id - ' || p_upload_id ||
				')(p_array_pos - ' || p_array_pos || ')'
                                , 10);
--
  l_string_apis := null;
  l_api_PVALS := null;
  l_generic_pval := null;

  --cache the column headings
  STORE_COLUMN_HEADINGS (p_line_id);


  --loops around all the column headings within the upload_line
  FOR i IN 1..230 LOOP
  --
    l_current_pval := LPAD(i,3,'0');
    l_current_pval := 'PVAL' || l_current_pval;
    --fetch the heading stored within the specified upload line
    l_pval_field   := g_column_headings(i);
    OPEN csr_parent_api_id;
    --
      FETCH csr_parent_api_id INTO l_parent_api_module_id;
      IF csr_parent_api_id%NOTFOUND THEN
      --no match on normal case so trying generic case
        OPEN csr_parent_table_column;
        --
          FETCH csr_parent_table_column INTO l_parent_table;
          IF csr_parent_table_column%FOUND THEN
            --loop through the column headings again to search for the
            --position in the line of where the api_module id will be stored
            hr_du_utility.message('INFO', l_parent_table, 15);
            FOR j IN 1..230 LOOP
            --
              l_inner_pval := LPAD(j,3,'0');
    	      l_inner_pval := 'PVAL' || l_inner_pval;

              l_inner_field   := g_column_headings(j);

              hr_du_utility.message('INFO', l_inner_field, 20);

	      IF l_parent_table = l_inner_field THEN
              --found the exact position in the line where the api_module id
              --from the calling table will be stored (l_inner_pval).
	      --
                --storing a null in l_string_apis will signal later on
                --that a generic column has been found
                l_string_apis := l_string_apis || null || ',';
                l_api_PVALS := l_api_PVALS || l_current_pval || ',';
 	        l_generic_pval := l_generic_pval || l_inner_pval || ',';
                EXIT;
	      --
              END IF;
            --
            END LOOP;
          END IF;
        --
        CLOSE csr_parent_table_column;
      --
      ELSE
      --
        hr_du_utility.message('INFO', l_parent_api_module_id , 25);
        l_string_apis := l_string_apis || l_parent_api_module_id || ',';
        l_api_PVALS := l_api_PVALS || l_current_pval || ',';
        l_generic_pval := l_generic_pval || null || ',';
      --
      END IF;
     --
    CLOSE csr_parent_api_id;
  END LOOP;

  l_length := LENGTHB(',');
  l_string_length := LENGTHB(l_string_apis);
  IF l_string_length > 0 THEN
    l_string_apis := SUBSTRB(l_string_apis,1,
                               (l_string_length - l_length));
    l_string_length := LENGTHB(l_api_PVALS);
    l_api_PVALS := SUBSTRB(l_api_PVALS,1,
                                 (l_string_length - l_length));
    l_string_length := LENGTHB(l_generic_pval);
    l_generic_pval := SUBSTRB(l_generic_pval,1,
                                 (l_string_length - l_length));
  END IF;

  --The commas are not removed from the strings for this causes errors
  --later on in the function PROCESS_LINE
  g_values_table(p_array_pos).r_parent_api_module_number := l_string_apis;
  g_values_table(p_array_pos).r_pval_parent_line_id := l_api_PVALS;
  g_values_table(p_array_pos).r_pval_api_module_number := l_generic_pval;

  hr_du_utility.message('INFO', l_api_PVALS , 35);
  hr_du_utility.message('INFO', l_string_apis , 30);
  hr_du_utility.message('INFO', l_generic_pval , 40);

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_do_datapump.referencing_columns',
                         45);
--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
                            'hr_du_do_datapump.referencing_columns',
                            '(none)', 'R');
    RAISE;
--
END REFERENCING_COLUMNS;



-- --------------------- CREATE_REFERENCING_STRINGS -----------------------
-- Description: Simple procedure that finds the line id which holds
-- the column headings, it then calls the relevant procedures.
--
--  Input Parameters
--        p_upload_id       - Identifies the upload over uploads simular
--                            to itself
--
--     p_table_position     - The row with in the PL/SQL table
--
--        p_api_module_id   - Identifies the api module
-- ------------------------------------------------------------------------
PROCEDURE CREATE_REFERENCING_STRINGS(p_upload_id IN VARCHAR2,
                                     p_table_position IN NUMBER,
                                     p_api_module_id IN NUMBER)
IS

  CURSOR csr_line_id IS
  SELECT line.UPLOAD_LINE_ID
    FROM hr_du_upload_headers head,
         hr_du_upload_lines   line
    WHERE head.upload_id = p_upload_id
    AND   head.api_module_id = p_api_module_id
    AND   line.upload_header_id = head.upload_header_id
    AND   line.LINE_TYPE = 'C';

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_line_id		NUMBER;

BEGIN

--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_do_datapump.create_referencing_strings', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id ||
			')(p_table_position - ' || p_table_position ||
			')(p_api_module_id - ' || p_api_module_id || ')'
                                , 10);
--

  OPEN csr_line_id;
    FETCH csr_line_id INTO l_line_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := 'No appropriate column title row exists in '||
                         'the HR_DU_UPLOAD_LINES for the api_module passed';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_line_id;

  hr_du_utility.message('INFO', 'l_line_id : ' || l_line_id, 15);

  REFERENCING_COLUMNS(l_line_id, p_api_module_id, p_upload_id,
                      p_table_position);


--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_do_datapump.create_referencing_strings', 30);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.main'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.create_referencing_strings'
                       ,'(none)', 'R');
    RAISE;
--
END CREATE_REFERENCING_STRINGS;


-- ------------------------- VALIDATE -----------------------------------
-- Description:
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
PROCEDURE VALIDATE(p_upload_id IN NUMBER) IS

CURSOR csr_validate_data IS
  SELECT line.UPLOAD_LINE_ID
    FROM hr_du_upload_headers head,
         hr_du_upload_lines   line
    WHERE head.upload_id = p_upload_id
    AND   line.upload_header_id = head.upload_header_id
    AND   line.REFERENCE_TYPE = 'CP';

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_upload_line_id	NUMBER;

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_do_datapump.validate', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--

  OPEN csr_validate_data;
    FETCH csr_validate_data INTO l_upload_line_id;
    IF csr_validate_data%NOTFOUND THEN
      l_fatal_error_message := 'Data is in an incorrect format to be ' ||
                               'taken into Data Pump. There are no Child '||
                               '- Parent references at all.';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_validate_data;


--
  hr_du_utility.message('ROUT','exit:hr_du_do_datapump.validate', 15);
--

--
EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.validate'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_do_datapump.validate',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE;


-- ------------------------- ROLLBACK -----------------------------------
-- Description: This procedure is called when an error has occured so that
-- the database tables can be cleaned up to restart the Data Output module
-- again
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
PROCEDURE ROLLBACK(p_upload_id IN NUMBER) IS

  l_temp		VARCHAR2(20);
  l_batch_id		NUMBER;
  l_batch_line		NUMBER;
  l_line_status		VARCHAR2(1);

CURSOR csr_batch_lines IS
  SELECT batch_line_id, line_status
  FROM   hr_pump_batch_lines
  WHERE  batch_id = l_batch_id;

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_do_datapump.rollback', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--


  UPDATE hr_du_upload_lines
  SET status = 'NS'
  WHERE UPLOAD_HEADER_ID IN (SELECT upload_header_id
                             FROM hr_du_upload_headers
                             WHERE upload_id = p_upload_id)
  AND status = 'S';

  SELECT BATCH_ID
    INTO l_batch_id
    FROM hr_du_uploads
    WHERE upload_id = p_upload_id;

--deletes the header from the batch exception
  DELETE FROM  hr_pump_batch_exceptions
  WHERE        source_id = l_batch_id
  AND	source_type = 'BATCH_HEADER';

  OPEN csr_batch_lines;
  LOOP
  --
    FETCH csr_batch_lines INTO l_batch_line, l_line_status;
      EXIT WHEN csr_batch_lines%NOTFOUND;

      --act upon the previous statement to delete approiate exceptions
      if l_line_status = 'E' Then
        DELETE FROM hr_pump_batch_exceptions
          WHERE 	source_id = l_batch_line
	  AND	source_type = 'BATCH_LINE';
      END IF;
      --insert extra code here to remove data from user keys in the future
      DELETE FROM HR_PUMP_BATCH_LINE_USER_KEYS
      where BATCH_LINE_ID = l_batch_line;
  --
  END LOOP;
  CLOSE csr_batch_lines;

  DELETE FROM hr_pump_batch_lines
  WHERE	batch_id = l_batch_id;

--deletes the data held within the pump ranges
  DELETE FROM hr_pump_ranges
  where batch_id = l_batch_id;

--deletes the data held within the pump requsts
  DELETE FROM hr_pump_requests
  WHERE BATCH_ID = l_batch_id;

  --include this statement here so that no foreign keys are violated
  UPDATE hr_du_uploads
  SET batch_id = null
  WHERE upload_id = p_upload_id;

-- deletes the info in the batch header
  DELETE FROM hr_pump_batch_headers
  WHERE BATCH_ID = l_batch_id;
  Commit;

--
  hr_du_utility.message('ROUT','exit:hr_du_do_datapump.rollback', 15);
--

--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_do_datapump.rollback',
                       '(none)', 'R');
    RAISE;
--
END ROLLBACK;


-- -------------------------------- MAIN ----------------------------------
-- Description: This procedure controls the flow of both
-- procedure and function calls to produce the output to Data Pump
--
--  Input Parameters
--      p_upload_id        - HR_DU_UPLOAD_ID to be used
--
-- ------------------------------------------------------------------------
PROCEDURE MAIN(p_upload_id IN NUMBER)
IS

  e_fatal_error 			EXCEPTION;
  l_fatal_error_message			VARCHAR2(2000);
  l_business_group			VARCHAR2(2000);
  l_table_size				NUMBER;
  l_api_name				VARCHAR2(100);
  l_api_name_thirty			VARCHAR2(100);
  l_process_order			NUMBER;
  l_batch_id				NUMBER;
  l_batch_name				VARCHAR2(2000);
  l_upload_line_id			NUMBER;
  l_upload_header_id			NUMBER;
  l_string_length			NUMBER;
  l_api_module_id			NUMBER;
  l_string_api				VARCHAR2(2000);
  l_upload_id				VARCHAR2(2000);
  l_length				NUMBER;
  l_cursor_handle			INT;
  l_rows_processed			INT;
  l_chunk_size_master			NUMBER;
  l_chunk_size_slave			NUMBER;
  l_pump_batch_line_id			NUMBER;


--This cursor extracts the batch name from the descriptors table
  CURSOR csr_batch_name IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE upper(DESCRIPTOR) = 'BATCH NAME'
    AND UPLOAD_ID = p_upload_id;

--Returns the upload line and header to be placed in Pump lines
  CURSOR csr_upload_line_id IS
  SELECT line.upload_line_id, line.upload_header_id
  FROM   hr_du_upload_lines     line,
         hr_du_upload_headers   head
  WHERE   head.upload_id = p_upload_id
   AND    head.api_module_id = l_api_module_id
   AND    line.upload_header_id = head.upload_header_id
   AND    line.status = 'NS'
   AND    line.reference_type = 'CP'
   AND    line.line_type = 'D';

BEGIN

--
  hr_du_utility.message('ROUT','entry:hr_du_do_datapump.main', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--

  SET_STATUS(p_upload_id);

-- clear globals
  g_values_table.DELETE;
  g_column_headings.DELETE;
  g_user_key_table.DELETE;


  --Places the data into the PL/SQL table in the correct processing order
  PRODUCE_TABLE(p_upload_id);

  --Returns the overall business group related to the HR_DU_UPLOAD.ID
  l_business_group := EXTRACT_BUSINESS_GROUP(p_upload_id);
  hr_du_utility.message('INFO','l_business_group : ' || l_business_group, 15);


  OPEN csr_batch_name;
    FETCH csr_batch_name INTO l_upload_id;
    IF csr_batch_name%NOTFOUND THEN
      l_fatal_error_message := 'Error BATCH NAME value not found in file';
      RAISE e_fatal_error;
    ELSE
      l_batch_name := SUBSTRB(l_upload_id,1,80);
    END IF;
  CLOSE csr_batch_name;



  --setting the batch name glueing the Batch Name, upload_id and the business
  --group
  l_length := LENGTHB(p_upload_id);
  IF l_length > 5 THEN
    l_upload_id := SUBSTRB(p_upload_id, (l_length - 4) ,l_length);
  ELSE
    l_upload_id := p_upload_id;
  END IF;



  l_batch_name := l_batch_name || '-' || l_upload_id;
  l_batch_name := SUBSTRB(l_batch_name, 1, 80);

  --find out the size of the PL/SQL table
  l_table_size := g_values_table.count;

  --create batch header storing the id
  l_batch_id := hr_pump_utils.create_batch_header
                (l_batch_name,l_business_group);

  -- set fnd_conc_global.set_req_globals
  -- for GL sync use

  fnd_conc_global.set_req_globals(request_data => to_char(l_batch_id));


  hr_du_utility.message('INFO','l_batch_id : ' || l_batch_id, 20);


  UPDATE hr_du_uploads
  SET batch_id = l_batch_id
  WHERE upload_id = p_upload_id;
  COMMIT;

  FOR i IN 1..l_table_size LOOP
  --
    hr_du_utility.message('INFO','api_module id : ' ||
                          g_values_table(i).r_api_id, 25);

    --Procedure call to fill in R_PVAL_PARENT_LINE_ID,
    --R_PARENT_api_module_NUMBER, R_PVAL_api_module_NUMBER
    CREATE_REFERENCING_STRINGS(p_upload_id, i, g_values_table(i).r_api_id);

    hr_du_utility.message('INFO','r_parent_api_module_number       : ' ||
                        g_values_table(i).r_parent_api_module_number , 15);
    hr_du_utility.message('INFO','r_pval_parent_line_id        : ' ||
                        g_values_table(i).r_pval_parent_line_id , 15);
    hr_du_utility.message('INFO','r_pval_api_module_number : ' ||
                        g_values_table(i).r_pval_api_module_number , 15);

  --
  END LOOP;

  --procedure call to insert the appropriate values into R_USER_KEY_PVAL
  CREATE_USER_KEY_STRING(p_upload_id, l_table_size);


  FOR i IN 1..l_table_size LOOP
    l_api_name :=  hr_du_dp_pc_conversion.return_field_value
                          ('HR_API_MODULES', g_values_table(i).r_api_id,
                           'API_MODULE_ID', 'MODULE_NAME');

    l_api_module_id := g_values_table(i).r_api_id;

    --this is here for the user_sequence value
    l_process_order := API_id_to_process_order(l_api_module_id,
                                               p_upload_id);

    hr_du_utility.message('INFO','l_api_name : ' || l_api_name , 20);
    hr_du_utility.message('INFO','l_process_order : ' || l_process_order, 20);


    --Making sure that the api name is the correct length for when the Meta
    --Mapper has been run it's rounded to 30 characters including HRDPV_

    l_length := LENGTHB(l_api_name);
    IF l_length > 24 THEN
      l_api_name_thirty := SUBSTRB(l_api_name, 1 , 24);
    ELSE
      l_api_name_thirty := l_api_name;
    END IF;

    l_chunk_size_master := hr_du_utility.chunk_size;
    l_chunk_size_slave := l_chunk_size_master;


    OPEN csr_upload_line_id;
    LOOP
      BEGIN
        FETCH csr_upload_line_id INTO l_upload_line_id, l_upload_header_id;
        IF csr_upload_line_id%NOTFOUND THEN
          --No lines left to process so EXIT's out of the loop
          EXIT;
        END IF;
      END;

      Select hr_pump_batch_lines_s.nextval
      INTO l_pump_batch_line_id
      FROM dual;

      --change the status of the PC row to show we're processing this
      UPDATE hr_du_upload_lines
      SET    status = 'S'
      WHERE  upload_line_id = l_upload_line_id;

      --If statements inserted here to call the appropriate procedure within
      --HR_DU_DO_ENTITIES so that the insert statements are build up correctly

      hr_du_utility.message('INFO',upper(l_api_name), 20);

      IF upper(l_api_name) = 'CREATE_US_EMPLOYEE' OR
         upper(l_api_name) = 'CREATE_GB_EMPLOYEE' THEN
        hr_du_do_entities.CREATE_DEFAULT_EMPLOYEE(g_values_table(i), p_upload_id,
                          l_batch_id, l_api_module_id, l_process_order,
                          l_upload_line_id, l_api_name_thirty, l_pump_batch_line_id);
      ELSIF upper(l_api_name) = 'UPDATE_EMP_ASG_CRITERIA' THEN
        hr_du_do_entities.UPDATE_EMP_ASG_CRITERIA(g_values_table(i),
                          p_upload_id, l_batch_id, l_api_module_id,
                          l_process_order, l_upload_line_id, l_api_name_thirty,
                          l_pump_batch_line_id);
      ELSIF g_values_table(i).r_user_key_pval IS NULL THEN
        hr_du_do_entities.DEFAULT_API_NULL(g_values_table(i), p_upload_id,
                          l_batch_id, l_api_module_id, l_process_order,
                          l_upload_line_id, l_api_name_thirty,l_pump_batch_line_id);
      ELSE
        hr_du_do_entities.DEFAULT_API(g_values_table(i), p_upload_id,
                          l_batch_id, l_api_module_id, l_process_order,
                          l_upload_line_id, l_api_name_thirty,l_pump_batch_line_id);
      END IF;

      --change the status of the PC row to show we're processing this
      --and connect the HR_DU_UPLOAD_LINE to the HR_PUMP_BATCH_LINE
      UPDATE hr_du_upload_lines
      SET    status = 'C',
             batch_line_id = l_pump_batch_line_id
      WHERE  upload_line_id = l_upload_line_id;

      --statement to commit every <CHUNK_SIZE>
      IF l_chunk_size_slave = 0 THEN
        COMMIT;
        l_chunk_size_slave := l_chunk_size_master;
      ELSE
        l_chunk_size_slave := l_chunk_size_slave - 1;
      END IF;

    END LOOP;
    CLOSE csr_upload_line_id;
    COMMIT;
  --
  END LOOP;

--
  hr_du_utility.message('ROUT','exit:hr_du_do_datapump.main', 20);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_datapump.main'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_do_datapump.main','(none)', 'R');
    RAISE;
--
END MAIN;


END HR_DU_DO_DATAPUMP;

/
