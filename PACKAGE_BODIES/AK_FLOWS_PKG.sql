--------------------------------------------------------
--  DDL for Package Body AK_FLOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_FLOWS_PKG" as
/* $Header: AKDFLOWB.pls 115.3 99/07/17 15:15:38 porting s $ */

procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_FLOW_APPLICATION_ID in NUMBER,
  X_FLOW_CODE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_PRIMARY_PAGE_APPL_ID in NUMBER,
  X_PRIMARY_PAGE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AK_FLOWS
    where FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
    and FLOW_CODE = X_FLOW_CODE;
begin
  insert into AK_FLOWS (
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    FLOW_APPLICATION_ID,
    FLOW_CODE,
    PRIMARY_PAGE_APPL_ID,
    PRIMARY_PAGE_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_FLOW_APPLICATION_ID,
    X_FLOW_CODE,
    X_PRIMARY_PAGE_APPL_ID,
    X_PRIMARY_PAGE_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  insert into AK_FLOWS_TL (
    FLOW_APPLICATION_ID,
    FLOW_CODE,
    LANGUAGE,
    NAME,
    DESCRIPTION,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    X_FLOW_APPLICATION_ID,
    X_FLOW_CODE,
    L.LANGUAGE_CODE,
    X_NAME,
    X_DESCRIPTION,
    userenv('LANG'),
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AK_FLOWS_TL T
    where T.FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
    and T.FLOW_CODE = X_FLOW_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;


procedure LOCK_ROW (
  X_FLOW_APPLICATION_ID in NUMBER,
  X_FLOW_CODE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_PRIMARY_PAGE_APPL_ID in NUMBER,
  X_PRIMARY_PAGE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      PRIMARY_PAGE_APPL_ID,
      PRIMARY_PAGE_CODE
    from AK_FLOWS
    where FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
    and FLOW_CODE = X_FLOW_CODE
    for update of FLOW_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION
    from AK_FLOWS_TL
    where FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
    and FLOW_CODE = X_FLOW_CODE
    and LANGUAGE = userenv('LANG')
    for update of FLOW_CODE nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
      if ( ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND (recinfo.PRIMARY_PAGE_APPL_ID = X_PRIMARY_PAGE_APPL_ID)
      AND (recinfo.PRIMARY_PAGE_CODE = X_PRIMARY_PAGE_CODE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.NAME = X_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_FLOW_APPLICATION_ID in NUMBER,
  X_FLOW_CODE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_PRIMARY_PAGE_APPL_ID in NUMBER,
  X_PRIMARY_PAGE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
    update AK_FLOWS set
      ATTRIBUTE1 = X_ATTRIBUTE1,
      ATTRIBUTE2 = X_ATTRIBUTE2,
      ATTRIBUTE3 = X_ATTRIBUTE3,
      ATTRIBUTE4 = X_ATTRIBUTE4,
      ATTRIBUTE5 = X_ATTRIBUTE5,
      ATTRIBUTE6 = X_ATTRIBUTE6,
      ATTRIBUTE7 = X_ATTRIBUTE7,
      ATTRIBUTE8 = X_ATTRIBUTE8,
      ATTRIBUTE9 = X_ATTRIBUTE9,
      ATTRIBUTE10 = X_ATTRIBUTE10,
      ATTRIBUTE11 = X_ATTRIBUTE11,
      ATTRIBUTE12 = X_ATTRIBUTE12,
      ATTRIBUTE13 = X_ATTRIBUTE13,
      ATTRIBUTE14 = X_ATTRIBUTE14,
      ATTRIBUTE15 = X_ATTRIBUTE15,
      ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
      FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID,
      FLOW_CODE = X_FLOW_CODE,
      PRIMARY_PAGE_APPL_ID = X_PRIMARY_PAGE_APPL_ID,
      PRIMARY_PAGE_CODE = X_PRIMARY_PAGE_CODE,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
    and FLOW_CODE = X_FLOW_CODE;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AK_FLOWS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FLOW_CODE = X_FLOW_CODE
  and FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_FLOW_APPLICATION_ID in NUMBER,
  X_FLOW_CODE in VARCHAR2
) is
begin
  delete from AK_FLOWS
  where FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
  and FLOW_CODE = X_FLOW_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AK_FLOWS_TL
  where FLOW_APPLICATION_ID = X_FLOW_APPLICATION_ID
  and FLOW_CODE = X_FLOW_CODE;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from AK_FLOWS_TL T
  where not exists
    (select NULL
    from AK_FLOWS B
    where B.FLOW_CODE = T.FLOW_CODE
    and B.FLOW_APPLICATION_ID = T.FLOW_APPLICATION_ID
    );

  update AK_FLOWS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AK_FLOWS_TL B
    where B.FLOW_CODE = T.FLOW_CODE
    and B.FLOW_APPLICATION_ID = T.FLOW_APPLICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FLOW_CODE,
      T.FLOW_APPLICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FLOW_CODE,
      SUBT.FLOW_APPLICATION_ID,
      SUBT.LANGUAGE
    from AK_FLOWS_TL SUBB, AK_FLOWS_TL SUBT
    where SUBB.FLOW_CODE = SUBT.FLOW_CODE
    and SUBB.FLOW_APPLICATION_ID = SUBT.FLOW_APPLICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AK_FLOWS_TL (
    FLOW_APPLICATION_ID,
    FLOW_CODE,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FLOW_APPLICATION_ID,
    B.FLOW_CODE,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AK_FLOWS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AK_FLOWS_TL T
    where T.FLOW_CODE = B.FLOW_CODE
    and T.FLOW_APPLICATION_ID = B.FLOW_APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE  copy_records
(	p_o_code	in varchar2,
	p_o_id		in number,
	p_n_code	in varchar2,
	p_n_id		in number) IS
	-- Various FLOW record type
	f_rec		ak_flows%rowtype;

	-- FLOW cursors
	cursor f_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
		select	*
		from	ak_flows
		where	flow_code = p_csr_code
		and	flow_application_id = p_csr_id;
	cursor ft_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
		select	*
		from	ak_flows_tl
		where	flow_code = p_csr_code
		and	flow_application_id = p_csr_id;
	cursor fp_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
		select	*
		from	ak_flow_pages
		where	flow_code = p_csr_code
		and	flow_application_id = p_csr_id;
	cursor fpt_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
		select	*
		from	ak_flow_pages_tl
		where	flow_code = p_csr_code
		and	flow_application_id = p_csr_id;
	cursor fpr_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
		select	*
		from	ak_flow_page_regions
		where	flow_code = p_csr_code
		and	flow_application_id = p_csr_id;
	cursor fpri_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
		select	*
		from	ak_flow_page_region_items
		where	flow_code = p_csr_code
		and	flow_application_id = p_csr_id;
	cursor frr_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
		select	*
		from	ak_flow_region_relations
		where	flow_code = p_csr_code
		and	flow_application_id = p_csr_id;

	-- Misc variables to be used
	b_success	boolean;
BEGIN
	open f_csr( p_o_code, p_o_id);
	FETCH f_csr INTO f_rec;
	b_success := f_csr%found;
	close f_csr;
	-- AK_FLOWS is a parent table. If you can't find a record, exit with an error message.
	if (not b_success) then
		fnd_message.set_name('AK', 'AK_NEW_FLOW_ALREADY_EXISTS');
		app_exception.raise_exception;
	end if;
	-- Put new code and id into record and insert into appropriate table
	f_rec.flow_code			:= p_n_code;
	f_rec.flow_application_id	:= p_n_id;

	insert into AK_FLOWS (
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE_CATEGORY,
		FLOW_APPLICATION_ID,
		FLOW_CODE,
		PRIMARY_PAGE_APPL_ID,
		PRIMARY_PAGE_CODE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	) values (
		f_rec.ATTRIBUTE1,
		f_rec.ATTRIBUTE2,
		f_rec.ATTRIBUTE3,
		f_rec.ATTRIBUTE4,
		f_rec.ATTRIBUTE5,
		f_rec.ATTRIBUTE6,
		f_rec.ATTRIBUTE7,
		f_rec.ATTRIBUTE8,
		f_rec.ATTRIBUTE9,
		f_rec.ATTRIBUTE10,
		f_rec.ATTRIBUTE11,
		f_rec.ATTRIBUTE12,
		f_rec.ATTRIBUTE13,
		f_rec.ATTRIBUTE14,
		f_rec.ATTRIBUTE15,
		f_rec.ATTRIBUTE_CATEGORY,
		f_rec.FLOW_APPLICATION_ID,
		f_rec.FLOW_CODE,
		f_rec.PRIMARY_PAGE_APPL_ID,
		f_rec.PRIMARY_PAGE_CODE,
		f_rec.CREATION_DATE,
		f_rec.CREATED_BY,
		f_rec.LAST_UPDATE_DATE,
		f_rec.LAST_UPDATED_BY,
		f_rec.LAST_UPDATE_LOGIN
	);

	FOR ft_rec IN ft_csr( p_o_code, p_o_id) LOOP
		-- Put new code and id into record and insert into appropriate table
		ft_rec.flow_code		:= p_n_code;
		ft_rec.flow_application_id	:= p_n_id;
		insert into AK_FLOWS_TL (
			FLOW_APPLICATION_ID,
			FLOW_CODE,
			LANGUAGE,
			NAME,
			DESCRIPTION,
			SOURCE_LANG,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN
		) values (
			ft_rec.FLOW_APPLICATION_ID,
			ft_rec.FLOW_CODE,
			ft_rec.LANGUAGE,
			ft_rec.NAME,
			ft_rec.DESCRIPTION,
			ft_rec.SOURCE_LANG,
			ft_rec.CREATED_BY,
			ft_rec.CREATION_DATE,
			ft_rec.LAST_UPDATED_BY,
			ft_rec.LAST_UPDATE_DATE,
			ft_rec.LAST_UPDATE_LOGIN
		);
	END LOOP;

	FOR fp_rec IN fp_csr( p_o_code, p_o_id) LOOP
		-- Put new code and id into record and insert into appropriate table
		fp_rec.flow_code		:= p_n_code;
		fp_rec.flow_application_id	:= p_n_id;

		insert into AK_FLOW_PAGES (
			FLOW_APPLICATION_ID,
			FLOW_CODE,
			PAGE_APPLICATION_ID,
			PAGE_CODE,
			PRIMARY_REGION_APPL_ID,
			PRIMARY_REGION_CODE,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15
		) values (
			fp_rec.FLOW_APPLICATION_ID,
			fp_rec.FLOW_CODE,
			fp_rec.PAGE_APPLICATION_ID,
			fp_rec.PAGE_CODE,
			fp_rec.PRIMARY_REGION_APPL_ID,
			fp_rec.PRIMARY_REGION_CODE,
			fp_rec.CREATION_DATE,
			fp_rec.CREATED_BY,
			fp_rec.LAST_UPDATE_DATE,
			fp_rec.LAST_UPDATED_BY,
			fp_rec.LAST_UPDATE_LOGIN,
			fp_rec.ATTRIBUTE_CATEGORY,
			fp_rec.ATTRIBUTE1,
			fp_rec.ATTRIBUTE2,
			fp_rec.ATTRIBUTE3,
			fp_rec.ATTRIBUTE4,
			fp_rec.ATTRIBUTE5,
			fp_rec.ATTRIBUTE6,
			fp_rec.ATTRIBUTE7,
			fp_rec.ATTRIBUTE8,
			fp_rec.ATTRIBUTE9,
			fp_rec.ATTRIBUTE10,
			fp_rec.ATTRIBUTE11,
			fp_rec.ATTRIBUTE12,
			fp_rec.ATTRIBUTE13,
			fp_rec.ATTRIBUTE14,
			fp_rec.ATTRIBUTE15
		);
	END LOOP;

	FOR fpt_rec IN fpt_csr( p_o_code, p_o_id) LOOP
		-- Put new code and id into record and insert into appropriate table
		fpt_rec.flow_code		:= p_n_code;
		fpt_rec.flow_application_id	:= p_n_id;

		insert into AK_FLOW_PAGES_TL (
			FLOW_APPLICATION_ID,
			FLOW_CODE,
			PAGE_APPLICATION_ID,
			PAGE_CODE,
			LANGUAGE,
			NAME,
			DESCRIPTION,
			SOURCE_LANG,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN
		) values (
			fpt_rec.FLOW_APPLICATION_ID,
			fpt_rec.FLOW_CODE,
			fpt_rec.PAGE_APPLICATION_ID,
			fpt_rec.PAGE_CODE,
			fpt_rec.LANGUAGE,
			fpt_rec.NAME,
			fpt_rec.DESCRIPTION,
			fpt_rec.SOURCE_LANG,
			fpt_rec.CREATED_BY,
			fpt_rec.CREATION_DATE,
			fpt_rec.LAST_UPDATED_BY,
			fpt_rec.LAST_UPDATE_DATE,
			fpt_rec.LAST_UPDATE_LOGIN
		);
	END LOOP;

	FOR fpr_rec IN fpr_csr( p_o_code, p_o_id) LOOP
		-- Put new code and id into record and insert into appropriate table
		fpr_rec.flow_code		:= p_n_code;
		fpr_rec.flow_application_id	:= p_n_id;

		insert into AK_FLOW_PAGE_REGIONS (
			FLOW_APPLICATION_ID,
			FLOW_CODE,
			PAGE_APPLICATION_ID,
			PAGE_CODE,
			REGION_APPLICATION_ID,
			REGION_CODE,
			DISPLAY_SEQUENCE,
			REGION_STYLE,
			NUM_COLUMNS,
			ICX_CUSTOM_CALL,
			PARENT_REGION_APPLICATION_ID,
			PARENT_REGION_CODE,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15
		) values (
			fpr_rec.FLOW_APPLICATION_ID,
			fpr_rec.FLOW_CODE,
			fpr_rec.PAGE_APPLICATION_ID,
			fpr_rec.PAGE_CODE,
			fpr_rec.REGION_APPLICATION_ID,
			fpr_rec.REGION_CODE,
			fpr_rec.DISPLAY_SEQUENCE,
			fpr_rec.REGION_STYLE,
			fpr_rec.NUM_COLUMNS,
			fpr_rec.ICX_CUSTOM_CALL,
			fpr_rec.PARENT_REGION_APPLICATION_ID,
			fpr_rec.PARENT_REGION_CODE,
			fpr_rec.CREATION_DATE,
			fpr_rec.CREATED_BY,
			fpr_rec.LAST_UPDATE_DATE,
			fpr_rec.LAST_UPDATED_BY,
			fpr_rec.LAST_UPDATE_LOGIN,
			fpr_rec.ATTRIBUTE_CATEGORY,
			fpr_rec.ATTRIBUTE1,
			fpr_rec.ATTRIBUTE2,
			fpr_rec.ATTRIBUTE3,
			fpr_rec.ATTRIBUTE4,
			fpr_rec.ATTRIBUTE5,
			fpr_rec.ATTRIBUTE6,
			fpr_rec.ATTRIBUTE7,
			fpr_rec.ATTRIBUTE8,
			fpr_rec.ATTRIBUTE9,
			fpr_rec.ATTRIBUTE10,
			fpr_rec.ATTRIBUTE11,
			fpr_rec.ATTRIBUTE12,
			fpr_rec.ATTRIBUTE13,
			fpr_rec.ATTRIBUTE14,
			fpr_rec.ATTRIBUTE15
		);
	END LOOP;

	FOR fpri_rec IN fpri_csr( p_o_code, p_o_id) LOOP
		-- Put new code and id into record and insert into appropriate table
		fpri_rec.flow_code		:= p_n_code;
		fpri_rec.flow_application_id	:= p_n_id;

		insert into AK_FLOW_PAGE_REGION_ITEMS (
			FLOW_APPLICATION_ID,
			FLOW_CODE,
			PAGE_APPLICATION_ID,
			PAGE_CODE,
			REGION_APPLICATION_ID,
			REGION_CODE,
			ATTRIBUTE_APPLICATION_ID,
			ATTRIBUTE_CODE,
			TO_PAGE_APPL_ID,
			TO_PAGE_CODE,
			TO_URL_ATTRIBUTE_APPL_ID,
			TO_URL_ATTRIBUTE_CODE,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15
		) values (
			fpri_rec.FLOW_APPLICATION_ID,
			fpri_rec.FLOW_CODE,
			fpri_rec.PAGE_APPLICATION_ID,
			fpri_rec.PAGE_CODE,
			fpri_rec.REGION_APPLICATION_ID,
			fpri_rec.REGION_CODE,
			fpri_rec.ATTRIBUTE_APPLICATION_ID,
			fpri_rec.ATTRIBUTE_CODE,
			fpri_rec.TO_PAGE_APPL_ID,
			fpri_rec.TO_PAGE_CODE,
			fpri_rec.TO_URL_ATTRIBUTE_APPL_ID,
			fpri_rec.TO_URL_ATTRIBUTE_CODE,
			fpri_rec.CREATION_DATE,
			fpri_rec.CREATED_BY,
			fpri_rec.LAST_UPDATE_DATE,
			fpri_rec.LAST_UPDATED_BY,
			fpri_rec.LAST_UPDATE_LOGIN,
			fpri_rec.ATTRIBUTE_CATEGORY,
			fpri_rec.ATTRIBUTE1,
			fpri_rec.ATTRIBUTE2,
			fpri_rec.ATTRIBUTE3,
			fpri_rec.ATTRIBUTE4,
			fpri_rec.ATTRIBUTE5,
			fpri_rec.ATTRIBUTE6,
			fpri_rec.ATTRIBUTE7,
			fpri_rec.ATTRIBUTE8,
			fpri_rec.ATTRIBUTE9,
			fpri_rec.ATTRIBUTE10,
			fpri_rec.ATTRIBUTE11,
			fpri_rec.ATTRIBUTE12,
			fpri_rec.ATTRIBUTE13,
			fpri_rec.ATTRIBUTE14,
			fpri_rec.ATTRIBUTE15
		);
	END LOOP;

	FOR frr_rec IN frr_csr( p_o_code, p_o_id) LOOP
		-- Put new code and id into record and insert into appropriate table
		frr_rec.flow_code		:= p_n_code;
		frr_rec.flow_application_id	:= p_n_id;

		insert into AK_FLOW_REGION_RELATIONS(
			FLOW_APPLICATION_ID,
			FLOW_CODE,
			FOREIGN_KEY_NAME,
			FROM_PAGE_APPL_ID,
			FROM_PAGE_CODE,
			FROM_REGION_APPL_ID,
			FROM_REGION_CODE,
			TO_PAGE_APPL_ID,
			TO_PAGE_CODE,
			TO_REGION_APPL_ID,
			TO_REGION_CODE,
			APPLICATION_ID,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15
		) values (
			frr_rec.FLOW_APPLICATION_ID,
			frr_rec.FLOW_CODE,
			frr_rec.FOREIGN_KEY_NAME,
			frr_rec.FROM_PAGE_APPL_ID,
			frr_rec.FROM_PAGE_CODE,
			frr_rec.FROM_REGION_APPL_ID,
			frr_rec.FROM_REGION_CODE,
			frr_rec.TO_PAGE_APPL_ID,
			frr_rec.TO_PAGE_CODE,
			frr_rec.TO_REGION_APPL_ID,
			frr_rec.TO_REGION_CODE,
			frr_rec.APPLICATION_ID,
			frr_rec.CREATION_DATE,
			frr_rec.CREATED_BY,
			frr_rec.LAST_UPDATE_DATE,
			frr_rec.LAST_UPDATED_BY,
			frr_rec.LAST_UPDATE_LOGIN,
			frr_rec.ATTRIBUTE_CATEGORY,
			frr_rec.ATTRIBUTE1,
			frr_rec.ATTRIBUTE2,
			frr_rec.ATTRIBUTE3,
			frr_rec.ATTRIBUTE4,
			frr_rec.ATTRIBUTE5,
			frr_rec.ATTRIBUTE6,
			frr_rec.ATTRIBUTE7,
			frr_rec.ATTRIBUTE8,
			frr_rec.ATTRIBUTE9,
			frr_rec.ATTRIBUTE10,
			frr_rec.ATTRIBUTE11,
			frr_rec.ATTRIBUTE12,
			frr_rec.ATTRIBUTE13,
			frr_rec.ATTRIBUTE14,
			frr_rec.ATTRIBUTE15
		);
	END LOOP;

END copy_records;

end AK_FLOWS_PKG;

/
