--------------------------------------------------------
--  DDL for Package Body PQH_PP_DFF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PP_DFF_UTILS" AS
/* $Header: pqhppdff.pkb 120.0 2006/02/06 14:45:12 rthiagar noship $ */


-- =============================================================================
-- ~ get_concat_dff_segs :
--   Function returns the concatenated string of Segment Values for a given DFFG
-- =============================================================================

FUNCTION get_concat_dff_segs
         (p_context_value In Varchar2
          ,p_attribute1   In Varchar2
          ,p_attribute2   In Varchar2
          ,p_attribute3   In Varchar2
          ,p_attribute4   In Varchar2
          ,p_attribute5   In Varchar2
          ,p_attribute6   In Varchar2
          ,p_attribute7   In Varchar2
          ,p_attribute8   In Varchar2
          ,p_attribute9   In Varchar2
          ,p_attribute10   In Varchar2
          ,p_attribute11   In Varchar2
          ,p_attribute12   In Varchar2
          ,p_attribute13   In Varchar2
          ,p_attribute14   In Varchar2
          ,p_attribute15   In Varchar2
          ,p_attribute16   In Varchar2
          ,p_attribute17   In Varchar2
          ,p_attribute18   In Varchar2
          ,p_attribute19   In Varchar2
          ,p_attribute20   In Varchar2
         )
RETURN Varchar2 IS

  -- Cursor to get Delimiter for a given DFF
  CURSOR csr_get_delim_contxt IS
  SELECT concatenated_segment_delimiter
    FROM fnd_descriptive_flexs
   WHERE descriptive_flexfield_name IN ('PER_PAY_PROPOSALS')
     AND application_id = 800;

  -- Cursor to get segments for a given DFF and Context
  CURSOR csr_get_segments(c_context_value IN Varchar2
                         ) IS
  SELECT descriptive_flex_context_code,application_column_name, flex_value_set_id
    FROM fnd_descr_flex_column_usages
   WHERE descriptive_flexfield_name = 'PER_PAY_PROPOSALS'
     AND descriptive_flex_context_code IN ('Global Data Elements', c_context_value)
     AND enabled_flag = 'Y'
     AND display_flag = 'Y'
     AND application_id = 800
   ORDER BY decode(descriptive_flex_context_code,'Global Data Elements',0,1), column_seq_num;

  l_func_name   CONSTANT    Varchar2(150):= g_pkg ||'pqh_concat_ddfsegs';

  l_delimiter               fnd_descriptive_flexs.concatenated_segment_delimiter%TYPE;

  l_cnct_segs               Varchar2(2000);
  l_cnct_seg_val            Varchar2(2000) ;
  cnt_attributes            integer := 0;
  cnt_glb_data_elmnts       integer := 0;
BEGIN

  Hr_Utility.set_location('Entering: '||l_func_name, 5);
  -- Get the Delimiter for the given DFF
  IF g_delimiter is null then
     OPEN  csr_get_delim_contxt;
     FETCH csr_get_delim_contxt INTO g_delimiter;

     -- If Delimiter is not found then that means the passed DFF doesn't exist
     -- for the passed application id. Raise an Error
     IF csr_get_delim_contxt%NOTFOUND THEN
        CLOSE csr_get_delim_contxt;
        Hr_Utility.raise_error;
     END IF;
     CLOSE csr_get_delim_contxt;
   END IF;

  l_delimiter := g_delimiter;

  -- Get the Segments for a given DFF and corresponding Context and
  -- Global Data Elements Context

  for l_seg_val_rec in csr_get_segments(c_context_value => p_context_value)
  LOOP
    l_cnct_segs := l_seg_val_rec.application_column_name;

    if ((l_seg_val_rec.descriptive_flex_context_code <> 'Global Data Elements') and cnt_attributes = 0 and cnt_glb_data_elmnts=0) then
         l_cnct_seg_val := p_context_value;
         cnt_glb_data_elmnts := 1;
    elsif ((l_seg_val_rec.descriptive_flex_context_code <> 'Global Data Elements') and cnt_glb_data_elmnts = 0) then
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_context_value;
         cnt_glb_data_elmnts := 1;
    end if;

    if  (l_cnct_segs = 'ATTRIBUTE1') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute1;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute1;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE2') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute2;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute2;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE3') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute3;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute3;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE4') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute4;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute4;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE5') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute5;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute5;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE6') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute6;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute6;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE7') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute7;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute7;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE8') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute8;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute8;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE9') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute9;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute9;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE10') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute10;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute10;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE11') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute11;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute11;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE12') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute12;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute12;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE13') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute13;
            cnt_attributes := cnt_attributes+1;
         else
            l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute13;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE14') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute14;
            cnt_attributes := cnt_attributes+1;
         else
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute14;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE15') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute15;
            cnt_attributes := cnt_attributes+1;
         else
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute15;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE16') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute16;
            cnt_attributes := cnt_attributes+1;
         else
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute16;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE17') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute17;
            cnt_attributes := cnt_attributes+1;
         else
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute17;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE18') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute18;
            cnt_attributes := cnt_attributes+1;
         else
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute18;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE19') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute19;
            cnt_attributes := cnt_attributes+1;
         else
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute19;
         end if;
    elsif  (l_cnct_segs = 'ATTRIBUTE20') then
         if (cnt_attributes = 0) then
            l_cnct_seg_val := p_attribute20;
            cnt_attributes := cnt_attributes+1;
         else
         l_cnct_seg_val := l_cnct_seg_val || l_delimiter || p_attribute20;
         end if;
    end if;
  END LOOP;


     RETURN l_cnct_seg_val;

  Hr_Utility.set_location('Leaving: '||l_func_name, 10);

END get_concat_dff_segs;
END PQH_PP_DFF_UTILS;


/
