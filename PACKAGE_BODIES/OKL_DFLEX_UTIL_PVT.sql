--------------------------------------------------------
--  DDL for Package Body OKL_DFLEX_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DFLEX_UTIL_PVT" AS
/* $Header: OKLRDFUB.pls 120.3 2006/02/23 18:19:20 rpillay noship $ */

  TYPE seg_info_rec_type IS RECORD
   (col1  varchar2(30)
   ,col2  varchar2(255)
    );
  --
  TYPE seg_info_tbl_type IS TABLE OF seg_info_rec_type INDEX BY BINARY_INTEGER;

  G_API_TYPE		CONSTANT VARCHAR2(4) := '_PVT';

procedure print(s in varchar2) is
begin
  fnd_file.put_line(fnd_file.log, s);
end;

-- ----------------------------------------------------------------------------
-- |------------------------<     find_error_segment      >-------------------|
-- ----------------------------------------------------------------------------
--
procedure find_error_segment(p_appl_short_name      IN  varchar2,
                             p_flexfield_name       IN  varchar2,
                             p_context_code         IN  varchar2,
                             p_error_seg_num        IN  number,
                             p_application_col_name OUT NOCOPY varchar2,
                             p_form_left_prompt     OUT NOCOPY varchar2,
                             p_table_name           OUT NOCOPY varchar2
                            )is
--
-- Cursors
--
CURSOR c_context_valid(p_appl_short_name in VARCHAR2,
                       p_flexfield_name in VARCHAR2,
                       p_context in VARCHAR2) is
SELECT 'Y'
FROM fnd_application a,
     fnd_descr_flex_contexts dfc
WHERE a.application_short_name = p_appl_short_name
AND a.application_id = dfc.application_id
AND dfc.descriptive_flexfield_name = p_flexfield_name
AND dfc.descriptive_flex_context_code = p_context;
--
-- Local Variables
--
l_api_name		  CONSTANT VARCHAR2(30) := 'FIND_ERROR_SEGMENT';
l_api_version	  CONSTANT NUMBER	      := 1.0;
l_return_status	  VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

l_flexfield         fnd_dflex.dflex_r;
l_flexinfo          fnd_dflex.dflex_dr;
l_global_context    fnd_dflex.context_r;
l_context           fnd_dflex.context_r;
l_global_segments   fnd_dflex.segments_dr;
l_global_count      number :=0;
l_segments          fnd_dflex.segments_dr;
l_segment_info      seg_info_tbl_type;
l_counter	        number :=0;
l_check_segments    BOOLEAN := TRUE;
l_exists            varchar2(2);
l_error_seg_num     number;

begin

--
-- First get the flexfield information
--
  fnd_dflex.get_flexfield(appl_short_name => p_appl_short_name,
                        flexfield_name  => p_flexfield_name,
                        flexfield       => l_flexfield,
                        flexinfo        => l_flexinfo);
--
-- Use l_flexfield in calls that follow to identify the flexfield.
-- Next check that the context is valid, otherwise return the context
-- column name and prompt
--
--
  if (p_error_seg_num is null) then
--
--   The context is in error, and the context is not one of the global
--   data elements.  In this case, we should simply set the application
--   column name and the context prompt to those associated with the
--   context information defined for this flexfield.

     p_application_col_name := l_flexinfo.context_column_name;
     p_form_left_prompt := l_flexinfo.form_context_prompt;
     p_table_name := l_flexinfo.table_name;
--
--   Since we know that the context was invalid, we don't have to check
--   the segments.
--
       l_check_segments := FALSE;
--
  else

     if p_context_code is not null then
       open c_context_valid(p_appl_short_name, p_flexfield_name, p_context_code);
       fetch c_context_valid into l_exists;
--
-- If this cursor did not return a record, we have an invalid context.
--
       if c_context_valid%NOTFOUND then
         p_application_col_name := l_flexinfo.context_column_name;
         p_form_left_prompt := l_flexinfo.form_context_prompt;
         p_table_name := l_flexinfo.table_name;
--
-- Since we know we have an invalid context, we need not check the segments.
--
         l_check_segments := FALSE;
      end if;
      close c_context_valid;
     end if; -- Not null context code
  end if;

  if l_check_segments then
--
-- First set up the Global Data Elements flexfield context, which is
-- always called 'Global Data Elements', as is not translated.
--
     l_global_context := fnd_dflex.make_context(flexfield => l_flexfield,
                                   context_code => 'Global Data Elements');

     fnd_dflex.get_segments(context => l_global_context,
                            segments => l_global_segments,
                            enabled_only => true);

     if (l_global_segments.application_column_name.count > 0) then

       for l_counter in l_global_segments.application_column_name.first..
                         l_global_segments.application_column_name.last loop

         l_segment_info(l_counter).col1 :=
                        l_global_segments.application_column_name(l_counter);
         l_segment_info(l_counter).col2 := l_global_segments.row_prompt(l_counter);
         l_global_count := l_global_count+1;
       end loop;
     else
       l_global_count := 0;
     end if;
--
-- Add information about the context column
--
     l_global_count := l_global_count +1;

     l_segment_info(l_global_count).col1 := l_flexinfo.context_column_name;
     l_segment_info(l_global_count).col2 := l_flexinfo.form_context_prompt;
--
-- Next get the specific information if the context is not global data elements
--
     if (p_context_code is not null) then

       l_context := fnd_dflex.make_context(flexfield => l_flexfield,
                                           context_code => p_context_code);
--
-- Retrieve the segment information for this context
--
       fnd_dflex.get_segments(context => l_context,
                              segments => l_segments,
                              enabled_only => true);
--
-- Append the specific context segment information to the Global Segment Information
-- again, checking that there is information to obtain
--
       if (l_segments.application_column_name.count > 0) then
           for l_counter in l_segments.application_column_name.first..
                            l_segments.application_column_name.last loop
               l_segment_info(l_counter+l_global_count).col1 :=
                         l_segments.application_column_name(l_counter);
               l_segment_info(l_counter+l_global_count).col2 :=
                         l_segments.row_prompt(l_counter);
           end loop;
       end if;
     end if;

--
-- Next retrieve the application column name corresponding to the segment
-- in error.
    p_application_col_name := l_segment_info(p_error_seg_num).col1;
    p_form_left_prompt := l_segment_info(p_error_seg_num).col2;
    p_table_name := l_flexinfo.table_name;
--
  end if;
--
end find_error_segment;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< validate_desc_flex >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE validate_desc_flex
  (p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_appl_short_name              IN  VARCHAR2
  ,p_descflex_name                IN  VARCHAR2
  ,p_segment_partial_name         IN  VARCHAR2
  ,p_segment_values_rec           IN  DFF_Rec_type
  )
IS
  --
  l_api_name      CONSTANT VARCHAR2(30) := 'VALIDATE_DESC_FLEX';
  l_api_version	CONSTANT NUMBER	    := 1.0;
  l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
  --
  l_attr_set          seg_info_tbl_type;
  l_attr_set_cnt      binary_integer;
  l_segment_set       seg_info_tbl_type;
  l_segment_cnt       binary_integer;
  l_seg_tbl_cnt       binary_integer;
  l_ne_attr_set       seg_info_tbl_type;
  --
  l_seg_column_name   varchar2(30);
  l_ne_column_name    varchar2(30);
  l_ne_column_value   varchar2(255);
  l_attr_name         varchar2(30);
  l_attr_value        varchar2(255);
  l_enab_seg_count    number;
  l_first_enab_segnum number;
  l_error_seg         number;
  i		          number;
  l_app_col_name      FND_DESCR_FLEX_COLUMN_USAGES.APPLICATION_COLUMN_NAME%TYPE;
  l_table_name        varchar2(60);
  l_flex_seg_error_prompt FND_DESCR_FLEX_COL_USAGE_TL.FORM_LEFT_PROMPT%TYPE;

  l_desc_col_name1  VARCHAR2(30) := p_segment_partial_name||'1';
  l_desc_col_name2  VARCHAR2(30) := p_segment_partial_name||'2';
  l_desc_col_name3  VARCHAR2(30) := p_segment_partial_name||'3';
  l_desc_col_name4  VARCHAR2(30) := p_segment_partial_name||'4';
  l_desc_col_name5  VARCHAR2(30) := p_segment_partial_name||'5';
  l_desc_col_name6  VARCHAR2(30) := p_segment_partial_name||'6';
  l_desc_col_name7  VARCHAR2(30) := p_segment_partial_name||'7';
  l_desc_col_name8  VARCHAR2(30) := p_segment_partial_name||'8';
  l_desc_col_name9  VARCHAR2(30) := p_segment_partial_name||'9';
  l_desc_col_name10 VARCHAR2(30) := p_segment_partial_name||'10';
  l_desc_col_name11 VARCHAR2(30) := p_segment_partial_name||'11';
  l_desc_col_name12 VARCHAR2(30) := p_segment_partial_name||'12';
  l_desc_col_name13 VARCHAR2(30) := p_segment_partial_name||'13';
  l_desc_col_name14 VARCHAR2(30) := p_segment_partial_name||'14';
  l_desc_col_name15 VARCHAR2(30) := p_segment_partial_name||'15';

  l_flexfield         fnd_dflex.dflex_r;
  l_flexinfo          fnd_dflex.dflex_dr;

  --  --------------------------------------------------------------------------
  --  |-----------------------< attribute_set_add_dtls >-----------------------|
  --  --------------------------------------------------------------------------
  --
  --  Add attribute details to a attribute set
  --
  PROCEDURE attribute_set_add_dtls
    (p_attr_set         IN OUT NOCOPY seg_info_tbl_type
    ,p_attr_set_row_num IN OUT NOCOPY NUMBER
    ,p_attr_name        IN VARCHAR2
    ,p_attr_value       IN VARCHAR2
    )
  IS
  BEGIN
      p_attr_set(p_attr_set_row_num).col1 := p_attr_name;
      p_attr_set(p_attr_set_row_num).col2 := p_attr_value;
      p_attr_set_row_num := p_attr_set_row_num + 1;
  END attribute_set_add_dtls;

  --  --------------------------------------------------------------------------
  --  |-----------------------------< get_non_exist_rows >----------------------|
  --  --------------------------------------------------------------------------
  --
  --  Get PLSQL Table rows which exist in p_seg_info_tbl1 but not p_seg_info_tbl2
  --
  PROCEDURE get_non_exist_rows
    (p_seg_info_tbl1  IN         seg_info_tbl_type
    ,p_seg_info_tbl2  IN         seg_info_tbl_type
    ,p_ne_tbl_rows    OUT NOCOPY seg_info_tbl_type
    )
  IS
    --
    l_api_name       CONSTANT VARCHAR2(30) := 'GET_NON_EXIST_ROWS';
    l_api_version	   CONSTANT NUMBER       := 1.0;
    l_return_status  VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    --
    l_tbl1_row       seg_info_rec_type;
    --
    l_tbl1_count     binary_integer;
    l_tbl2_count     binary_integer;
    l_ne_row_count   binary_integer;
    l_tbl1_ele_value varchar2(255);
    l_tbl2_ele_value varchar2(255);
    l_match_count    number;
    --
  BEGIN
    --
    -- Check if Table 1 contains rows
    --
    if p_seg_info_tbl1.count > 0 then
      --
      -- Loop through rows
      --
      l_ne_row_count := 0;
      --
      for l_tbl1_count in p_seg_info_tbl1.first .. p_seg_info_tbl1.last loop
        --
        l_tbl1_ele_value := p_seg_info_tbl1(l_tbl1_count).col1;
        --
        -- Check if Table 2 contains rows
        --
        if p_seg_info_tbl2.count > 0 then
          --
          -- Loop through rows
          --
          l_match_count := 0;
          --
          for l_tbl2_count in p_seg_info_tbl2.first .. p_seg_info_tbl2.last loop
            --
            l_tbl2_ele_value := p_seg_info_tbl2(l_tbl2_count).col1;
            --
            -- Check for a value match
            --
            if l_tbl1_ele_value = l_tbl2_ele_value then
              --
              l_match_count := l_match_count + 1;
              exit;
              --
            end if;
            --
          end loop;
          --
          -- Check for a non existant value
          --
          if l_match_count = 0 then
            --
            -- Set the NE row to a local row
            --
            l_tbl1_row := p_seg_info_tbl1(l_tbl1_count);
            --
            -- Add the NE row to the NE Table
            --
            p_ne_tbl_rows(l_ne_row_count) := l_tbl1_row;
            l_ne_row_count := l_ne_row_count + 1;
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  END get_non_exist_rows;
  --

BEGIN

   -- call START_ACTIVITY to create savepoint, check compatibility
   -- and initialize message list

   l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
     raise OKL_API.G_EXCEPTION_ERROR;
   End If;

   l_attr_set_cnt := 0;

   attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name1
    ,p_attr_value       => p_segment_values_rec.attribute1
    );

   attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name2
    ,p_attr_value       => p_segment_values_rec.attribute2
    );

   attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name3
    ,p_attr_value       => p_segment_values_rec.attribute3
    );

   attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name4
    ,p_attr_value       => p_segment_values_rec.attribute4
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name5
    ,p_attr_value       => p_segment_values_rec.attribute5
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name6
    ,p_attr_value       => p_segment_values_rec.attribute6
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name7
    ,p_attr_value       => p_segment_values_rec.attribute7
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name8
    ,p_attr_value       => p_segment_values_rec.attribute8
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name9
    ,p_attr_value       => p_segment_values_rec.attribute9
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name10
    ,p_attr_value       => p_segment_values_rec.attribute10
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name11
    ,p_attr_value       => p_segment_values_rec.attribute11
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name12
    ,p_attr_value       => p_segment_values_rec.attribute12
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name13
    ,p_attr_value       => p_segment_values_rec.attribute13
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name14
    ,p_attr_value       => p_segment_values_rec.attribute14
    );

    attribute_set_add_dtls
    (p_attr_set         => l_attr_set
    ,p_attr_set_row_num => l_attr_set_cnt
    ,p_attr_name        => l_desc_col_name15
    ,p_attr_value       => p_segment_values_rec.attribute15
    );

   fnd_flex_descval.set_context_value
     (p_segment_values_rec.attribute_category);

   if l_attr_set.count > 0 then
     --
     -- Loop through the attribute set
     --
     for l_attr_set_cnt in l_attr_set.first .. l_attr_set.last loop
       --
       l_attr_name  := l_attr_set(l_attr_set_cnt).col1;
       l_attr_value := l_attr_set(l_attr_set_cnt).col2;
       --
       -- Add attribute details to AOL DF column details
       --
       fnd_flex_descval.set_column_value
         (column_name  => l_attr_name
         ,column_value => l_attr_value
         );
       --
     end loop;
   end if;

   --
   -- Validate DF column details passed to AOL
   --
   if NOT FND_FLEX_DESCVAL.validate_desccols
      (appl_short_name  => p_appl_short_name
      ,desc_flex_name   => p_descflex_name
      ,values_or_ids    => 'I'
   )
   then

      l_error_seg := FND_FLEX_DESCVAL.error_segment;
      find_error_segment(p_appl_short_name      => p_appl_short_name,
                         p_flexfield_name       => p_descflex_name,
                         p_context_code         => p_segment_values_rec.attribute_category,
                         p_error_seg_num        => l_error_seg,
                         p_application_col_name => l_app_col_name,
                         p_form_left_prompt     => l_flex_seg_error_prompt,
                         p_table_name           => l_table_name
                         );

      OKL_API.SET_MESSAGE
        (p_app_name     => G_APP_NAME
        ,p_msg_name     => 'OKL_DESC_FLEX_ERROR'
        ,p_token1       => 'DESC_FLEX_MSG'
        ,p_token1_value =>  FND_FLEX_DESCVAL.error_message
        ,p_token2       => 'ERROR_SEGMENT'
        ,p_token2_value => l_flex_seg_error_prompt
        ,p_token3       => 'TABLE_NAME'
        ,p_token3_value => l_table_name
        ,p_token4       => 'DFF_NAME'
        ,p_token4_value => p_descflex_name
        ,p_token5       => 'CONTEXT_VALUE'
        ,p_token5_value => p_segment_values_rec.attribute_category);

      RAISE OKL_API.G_EXCEPTION_ERROR;
      --
   end if;  --  FND_FLEX_DESCVAL.validate_desccols
   --
   -- Build the segment set
   l_seg_tbl_cnt := 0;
   --
   l_first_enab_segnum := 1;
   --
   --   Get the enabled segment count
   --
   l_enab_seg_count := fnd_flex_descval.segment_count;
   --
   for l_segment_cnt in l_first_enab_segnum..l_enab_seg_count loop
     --
     -- Get the segment column name
     --
     l_seg_column_name := fnd_flex_descval.segment_column_name(l_segment_cnt);
     --
     -- Check if the column name is set
     --
     if l_seg_column_name is not null then
       --
       -- Populate the segment Table
       l_segment_set(l_seg_tbl_cnt).col1 := l_seg_column_name;
       l_seg_tbl_cnt := l_seg_tbl_cnt + 1;
     end if;
   --
   end loop;
   --
   -- Get Non Enabled attribute names
   --
   get_non_exist_rows
     (p_seg_info_tbl1  => l_attr_set
     ,p_seg_info_tbl2  => l_segment_set
     ,p_ne_tbl_rows    => l_ne_attr_set
     );
   --
   -- Check if non enabled attributes have been provided
   --
   if l_ne_attr_set.count > 0 then
     for x in l_ne_attr_set.first..l_ne_attr_set.last loop
       --
       -- Set the non enabled column name
       --
         l_ne_column_name  := l_ne_attr_set(x).col1;
         l_ne_column_value := l_ne_attr_set(x).col2;
       --
       -- Check if the value is set for the non enabled column
       --
       if l_ne_column_value is not null then
       --

         fnd_dflex.get_flexfield
           (appl_short_name => p_appl_short_name,
            flexfield_name  => p_descflex_name,
            flexfield       => l_flexfield,
            flexinfo        => l_flexinfo);

         OKL_API.SET_MESSAGE
           (p_app_name     => G_APP_NAME
           ,p_msg_name     => 'OKL_NON_EXIST_SEG_NAME'
           ,p_token1       => 'SEGMENT'
           ,p_token1_value => l_ne_column_name
           ,p_token2       => 'VALUE'
           ,p_token2_value => l_ne_column_value
           ,p_token3       => 'TABLE_NAME'
           ,p_token3_value => l_flexinfo.table_name
           ,p_token4       => 'DFF_NAME'
           ,p_token4_value => p_descflex_name
           ,p_token5       => 'CONTEXT_VALUE'
           ,p_token5_value => p_segment_values_rec.attribute_category);

         RAISE OKL_API.G_EXCEPTION_ERROR;
       --
       end if;
       --
     end loop;
   end if;

   OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data	 => x_msg_data);

EXCEPTION
 WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
END validate_desc_flex;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_contract_add_info >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_contract_add_info
  (p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_chr_id                       IN  NUMBER
  ,p_add_info_rec                 IN  DFF_Rec_type
  )
IS
  --
  l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_ADD_INFO';
  l_api_version	CONSTANT NUMBER	    := 1.0;
  l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
  --

  lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
  lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;

  lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
  lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
BEGIN

   -- call START_ACTIVITY to create savepoint, check compatibility
   -- and initialize message list

   l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
     raise OKL_API.G_EXCEPTION_ERROR;
   End If;

   lp_chrv_rec.id := p_chr_id;
   lp_khrv_rec.id := p_chr_id;

   lp_khrv_rec.attribute_category := p_add_info_rec.attribute_category;
   lp_khrv_rec.attribute1         := p_add_info_rec.attribute1;
   lp_khrv_rec.attribute2         := p_add_info_rec.attribute2;
   lp_khrv_rec.attribute3         := p_add_info_rec.attribute3;
   lp_khrv_rec.attribute4         := p_add_info_rec.attribute4;
   lp_khrv_rec.attribute5         := p_add_info_rec.attribute5;
   lp_khrv_rec.attribute6         := p_add_info_rec.attribute6;
   lp_khrv_rec.attribute7         := p_add_info_rec.attribute7;
   lp_khrv_rec.attribute8         := p_add_info_rec.attribute8;
   lp_khrv_rec.attribute9         := p_add_info_rec.attribute9;
   lp_khrv_rec.attribute10        := p_add_info_rec.attribute10;
   lp_khrv_rec.attribute11        := p_add_info_rec.attribute11;
   lp_khrv_rec.attribute12        := p_add_info_rec.attribute12;
   lp_khrv_rec.attribute13        := p_add_info_rec.attribute13;
   lp_khrv_rec.attribute14        := p_add_info_rec.attribute14;
   lp_khrv_rec.attribute15        := p_add_info_rec.attribute15;

   lp_khrv_rec.validate_dff_yn    := 'Y';

   OKL_CONTRACT_PUB.update_contract_header(
     p_api_version       => p_api_version,
     p_init_msg_list  	 => p_init_msg_list,
     x_return_status  	 => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,
     p_restricted_update => 'F',
     p_chrv_rec          => lp_chrv_rec,
     p_khrv_rec       	 => lp_khrv_rec,
     x_chrv_rec       	 => lx_chrv_rec,
     x_khrv_rec       	 => lx_khrv_rec);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data	 => x_msg_data);

EXCEPTION
 WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
END update_contract_add_info;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_line_add_info >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_line_add_info
  (p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_cle_id                       IN  NUMBER
  ,p_add_info_rec                 IN  DFF_Rec_type
  )
IS
  --
  l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_LINE_ADD_INFO';
  l_api_version	CONSTANT NUMBER	    := 1.0;
  l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
  --

  lp_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type;
  lx_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type;

  lp_klev_rec OKL_CONTRACT_PUB.klev_rec_type;
  lx_klev_rec OKL_CONTRACT_PUB.klev_rec_type;
BEGIN

   -- call START_ACTIVITY to create savepoint, check compatibility
   -- and initialize message list

   l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
     raise OKL_API.G_EXCEPTION_ERROR;
   End If;

   --Bug# 4959361
    OKL_LLA_UTIL_PVT.check_line_update_allowed
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_cle_id          => p_cle_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4959361

   lp_clev_rec.id := p_cle_id;
   lp_klev_rec.id := p_cle_id;

   lp_klev_rec.attribute_category := p_add_info_rec.attribute_category;
   lp_klev_rec.attribute1         := p_add_info_rec.attribute1;
   lp_klev_rec.attribute2         := p_add_info_rec.attribute2;
   lp_klev_rec.attribute3         := p_add_info_rec.attribute3;
   lp_klev_rec.attribute4         := p_add_info_rec.attribute4;
   lp_klev_rec.attribute5         := p_add_info_rec.attribute5;
   lp_klev_rec.attribute6         := p_add_info_rec.attribute6;
   lp_klev_rec.attribute7         := p_add_info_rec.attribute7;
   lp_klev_rec.attribute8         := p_add_info_rec.attribute8;
   lp_klev_rec.attribute9         := p_add_info_rec.attribute9;
   lp_klev_rec.attribute10        := p_add_info_rec.attribute10;
   lp_klev_rec.attribute11        := p_add_info_rec.attribute11;
   lp_klev_rec.attribute12        := p_add_info_rec.attribute12;
   lp_klev_rec.attribute13        := p_add_info_rec.attribute13;
   lp_klev_rec.attribute14        := p_add_info_rec.attribute14;
   lp_klev_rec.attribute15        := p_add_info_rec.attribute15;

   lp_klev_rec.validate_dff_yn    := 'Y';

   OKL_CONTRACT_PUB.update_contract_line(
     p_api_version       => p_api_version,
     p_init_msg_list  	 => p_init_msg_list,
     x_return_status  	 => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,
     p_clev_rec          => lp_clev_rec,
     p_klev_rec       	 => lp_klev_rec,
     x_clev_rec       	 => lx_clev_rec,
     x_klev_rec       	 => lx_klev_rec);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data	 => x_msg_data);

EXCEPTION
 WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS
              (l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT');
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OKL_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT');
     WHEN OTHERS THEN
     x_return_status :=OKL_API.HANDLE_EXCEPTIONS
             (l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PVT');
END update_line_add_info;
--

END OKL_DFLEX_UTIL_PVT;

/
