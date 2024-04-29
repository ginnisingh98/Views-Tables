--------------------------------------------------------
--  DDL for Package Body HR_WINDOW_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WINDOW_PROPERTIES_PKG" as
/* $Header: hrwnplct.pkb 115.5 2002/12/11 11:24:08 raranjan noship $ */
-- -----------------------------------------------------------------------------
-- |-----------------------------< update_copies >-----------------------------|
-- -----------------------------------------------------------------------------
procedure UPDATE_COPIES (
  X_WINDOW_PROPERTY_ID in NUMBER,
  X_FORM_WINDOW_ID in NUMBER,
  X_TEMPLATE_WINDOW_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_WIDTH in NUMBER,
  X_X_POSITION in NUMBER,
  X_Y_POSITION in NUMBER,
  X_TITLE in VARCHAR2,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor csr_original is
    select *
      from HR_WINDOW_PROPERTIES_VL
     where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID;
  l_original csr_original%rowtype;
  cursor csr_copies is
    select wnp.window_property_id
      from HR_WINDOW_PROPERTIES_B wnp
          ,HR_TEMPLATE_WINDOWS_B twn
          ,HR_TEMPLATE_WINDOWS_B two
     where wnp.TEMPLATE_WINDOW_ID = twn.TEMPLATE_WINDOW_ID
       and twn.FORM_TEMPLATE_ID in (select sft.FORM_TEMPLATE_ID_TO
                                      from HR_SOURCE_FORM_TEMPLATES sft
                                start with sft.FORM_TEMPLATE_ID_FROM = two.FORM_TEMPLATE_ID
                                connect by sft.FORM_TEMPLATE_ID_FROM = prior sft.FORM_TEMPLATE_ID_TO)
       and twn.FORM_WINDOW_ID = two.FORM_WINDOW_ID
       and two.TEMPLATE_WINDOW_ID = X_TEMPLATE_WINDOW_ID;
begin
  if (X_TEMPLATE_WINDOW_ID is not null) then
    open csr_original;
    fetch csr_original into l_original;
    if csr_original%found then
      close csr_original;
      for l_copy in csr_copies loop
        update HR_WINDOW_PROPERTIES_B set
          HEIGHT = decode(nvl(HEIGHT,hr_api.g_number),nvl(l_original.HEIGHT,hr_api.g_number),X_HEIGHT,HEIGHT),
          WIDTH = decode(nvl(WIDTH,hr_api.g_number),nvl(l_original.WIDTH,hr_api.g_number),X_WIDTH,WIDTH),
          X_POSITION = decode(nvl(X_POSITION,hr_api.g_number),nvl(l_original.X_POSITION,hr_api.g_number),X_X_POSITION,X_POSITION),
          Y_POSITION = decode(nvl(Y_POSITION,hr_api.g_number),nvl(l_original.Y_POSITION,hr_api.g_number),X_Y_POSITION,Y_POSITION),
          INFORMATION_CATEGORY = decode(nvl(INFORMATION_CATEGORY,hr_api.g_varchar2),nvl(l_original.INFORMATION_CATEGORY,hr_api.g_varchar2),X_INFORMATION_CATEGORY,INFORMATION_CATEGORY),
          INFORMATION1  = decode(nvl(INFORMATION1 ,hr_api.g_varchar2),nvl(l_original.INFORMATION1 ,hr_api.g_varchar2),X_INFORMATION1 ,INFORMATION1 ),
          INFORMATION2  = decode(nvl(INFORMATION2 ,hr_api.g_varchar2),nvl(l_original.INFORMATION2 ,hr_api.g_varchar2),X_INFORMATION2 ,INFORMATION2 ),
          INFORMATION3  = decode(nvl(INFORMATION3 ,hr_api.g_varchar2),nvl(l_original.INFORMATION3 ,hr_api.g_varchar2),X_INFORMATION3 ,INFORMATION3 ),
          INFORMATION4  = decode(nvl(INFORMATION4 ,hr_api.g_varchar2),nvl(l_original.INFORMATION4 ,hr_api.g_varchar2),X_INFORMATION4 ,INFORMATION4 ),
          INFORMATION5  = decode(nvl(INFORMATION5 ,hr_api.g_varchar2),nvl(l_original.INFORMATION5 ,hr_api.g_varchar2),X_INFORMATION5 ,INFORMATION5 ),
          INFORMATION6  = decode(nvl(INFORMATION6 ,hr_api.g_varchar2),nvl(l_original.INFORMATION6 ,hr_api.g_varchar2),X_INFORMATION6 ,INFORMATION6 ),
          INFORMATION7  = decode(nvl(INFORMATION7 ,hr_api.g_varchar2),nvl(l_original.INFORMATION7 ,hr_api.g_varchar2),X_INFORMATION7 ,INFORMATION7 ),
          INFORMATION8  = decode(nvl(INFORMATION8 ,hr_api.g_varchar2),nvl(l_original.INFORMATION8 ,hr_api.g_varchar2),X_INFORMATION8 ,INFORMATION8 ),
          INFORMATION9  = decode(nvl(INFORMATION9 ,hr_api.g_varchar2),nvl(l_original.INFORMATION9 ,hr_api.g_varchar2),X_INFORMATION9 ,INFORMATION9 ),
          INFORMATION10 = decode(nvl(INFORMATION10,hr_api.g_varchar2),nvl(l_original.INFORMATION10,hr_api.g_varchar2),X_INFORMATION10,INFORMATION10),
          INFORMATION11 = decode(nvl(INFORMATION11,hr_api.g_varchar2),nvl(l_original.INFORMATION11,hr_api.g_varchar2),X_INFORMATION11,INFORMATION11),
          INFORMATION12 = decode(nvl(INFORMATION12,hr_api.g_varchar2),nvl(l_original.INFORMATION12,hr_api.g_varchar2),X_INFORMATION12,INFORMATION12),
          INFORMATION13 = decode(nvl(INFORMATION13,hr_api.g_varchar2),nvl(l_original.INFORMATION13,hr_api.g_varchar2),X_INFORMATION13,INFORMATION13),
          INFORMATION14 = decode(nvl(INFORMATION14,hr_api.g_varchar2),nvl(l_original.INFORMATION14,hr_api.g_varchar2),X_INFORMATION14,INFORMATION14),
          INFORMATION15 = decode(nvl(INFORMATION15,hr_api.g_varchar2),nvl(l_original.INFORMATION15,hr_api.g_varchar2),X_INFORMATION15,INFORMATION15),
          INFORMATION16 = decode(nvl(INFORMATION16,hr_api.g_varchar2),nvl(l_original.INFORMATION16,hr_api.g_varchar2),X_INFORMATION16,INFORMATION16),
          INFORMATION17 = decode(nvl(INFORMATION17,hr_api.g_varchar2),nvl(l_original.INFORMATION17,hr_api.g_varchar2),X_INFORMATION17,INFORMATION17),
          INFORMATION18 = decode(nvl(INFORMATION18,hr_api.g_varchar2),nvl(l_original.INFORMATION18,hr_api.g_varchar2),X_INFORMATION18,INFORMATION18),
          INFORMATION19 = decode(nvl(INFORMATION19,hr_api.g_varchar2),nvl(l_original.INFORMATION19,hr_api.g_varchar2),X_INFORMATION19,INFORMATION19),
          INFORMATION20 = decode(nvl(INFORMATION20,hr_api.g_varchar2),nvl(l_original.INFORMATION20,hr_api.g_varchar2),X_INFORMATION20,INFORMATION20),
          INFORMATION21 = decode(nvl(INFORMATION21,hr_api.g_varchar2),nvl(l_original.INFORMATION21,hr_api.g_varchar2),X_INFORMATION21,INFORMATION21),
          INFORMATION22 = decode(nvl(INFORMATION22,hr_api.g_varchar2),nvl(l_original.INFORMATION22,hr_api.g_varchar2),X_INFORMATION22,INFORMATION22),
          INFORMATION23 = decode(nvl(INFORMATION23,hr_api.g_varchar2),nvl(l_original.INFORMATION23,hr_api.g_varchar2),X_INFORMATION23,INFORMATION23),
          INFORMATION24 = decode(nvl(INFORMATION24,hr_api.g_varchar2),nvl(l_original.INFORMATION24,hr_api.g_varchar2),X_INFORMATION24,INFORMATION24),
          INFORMATION25 = decode(nvl(INFORMATION25,hr_api.g_varchar2),nvl(l_original.INFORMATION25,hr_api.g_varchar2),X_INFORMATION25,INFORMATION25),
          INFORMATION26 = decode(nvl(INFORMATION26,hr_api.g_varchar2),nvl(l_original.INFORMATION26,hr_api.g_varchar2),X_INFORMATION26,INFORMATION26),
          INFORMATION27 = decode(nvl(INFORMATION27,hr_api.g_varchar2),nvl(l_original.INFORMATION27,hr_api.g_varchar2),X_INFORMATION27,INFORMATION27),
          INFORMATION28 = decode(nvl(INFORMATION28,hr_api.g_varchar2),nvl(l_original.INFORMATION28,hr_api.g_varchar2),X_INFORMATION28,INFORMATION28),
          INFORMATION29 = decode(nvl(INFORMATION29,hr_api.g_varchar2),nvl(l_original.INFORMATION29,hr_api.g_varchar2),X_INFORMATION29,INFORMATION29),
          INFORMATION30 = decode(nvl(INFORMATION30,hr_api.g_varchar2),nvl(l_original.INFORMATION30,hr_api.g_varchar2),X_INFORMATION30,INFORMATION30),
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
        where WINDOW_PROPERTY_ID = l_copy.WINDOW_PROPERTY_ID;
        if (sql%notfound) then
          raise no_data_found;
        end if;
        update HR_WINDOW_PROPERTIES_TL set
          TITLE = decode(nvl(TITLE,hr_api.g_varchar2),nvl(l_original.TITLE,hr_api.g_varchar2),X_TITLE,TITLE),
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          SOURCE_LANG = userenv('LANG')
        where WINDOW_PROPERTY_ID = l_copy.WINDOW_PROPERTY_ID
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
        if (sql%notfound) then
          raise no_data_found;
        end if;
      end loop;
    else
      close csr_original;
    end if;
  end if;
end UPDATE_COPIES;
--
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_WINDOW_PROPERTY_ID in NUMBER,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_X_POSITION in NUMBER,
  X_FORM_WINDOW_ID in NUMBER,
  X_TEMPLATE_WINDOW_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_WIDTH in NUMBER,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_Y_POSITION in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_WINDOW_PROPERTIES_B
    where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID
    ;
begin
  insert into HR_WINDOW_PROPERTIES_B (
    INFORMATION17,
    INFORMATION18,
    INFORMATION19,
    INFORMATION20,
    INFORMATION21,
    INFORMATION22,
    INFORMATION23,
    INFORMATION24,
    INFORMATION25,
    INFORMATION26,
    INFORMATION27,
    INFORMATION28,
    INFORMATION29,
    INFORMATION30,
    X_POSITION,
    FORM_WINDOW_ID,
    TEMPLATE_WINDOW_ID,
    HEIGHT,
    WIDTH,
    INFORMATION12,
    INFORMATION13,
    INFORMATION14,
    INFORMATION15,
    INFORMATION16,
    WINDOW_PROPERTY_ID,
    INFORMATION5,
    INFORMATION6,
    INFORMATION7,
    INFORMATION8,
    INFORMATION9,
    INFORMATION10,
    INFORMATION11,
    Y_POSITION,
    INFORMATION_CATEGORY,
    INFORMATION1,
    INFORMATION2,
    INFORMATION3,
    INFORMATION4,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_INFORMATION29,
    X_INFORMATION30,
    X_X_POSITION,
    X_FORM_WINDOW_ID,
    X_TEMPLATE_WINDOW_ID,
    X_HEIGHT,
    X_WIDTH,
    X_INFORMATION12,
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_WINDOW_PROPERTY_ID,
    X_INFORMATION5,
    X_INFORMATION6,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    X_Y_POSITION,
    X_INFORMATION_CATEGORY,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into HR_WINDOW_PROPERTIES_TL (
    WINDOW_PROPERTY_ID,
    TITLE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_WINDOW_PROPERTY_ID,
    X_TITLE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_WINDOW_PROPERTIES_TL T
    where T.WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_WINDOW_PROPERTY_ID in NUMBER,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_X_POSITION in NUMBER,
  X_FORM_WINDOW_ID in NUMBER,
  X_TEMPLATE_WINDOW_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_WIDTH in NUMBER,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_Y_POSITION in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_TITLE in VARCHAR2
) is
  cursor c is select
      INFORMATION17,
      INFORMATION18,
      INFORMATION19,
      INFORMATION20,
      INFORMATION21,
      INFORMATION22,
      INFORMATION23,
      INFORMATION24,
      INFORMATION25,
      INFORMATION26,
      INFORMATION27,
      INFORMATION28,
      INFORMATION29,
      INFORMATION30,
      X_POSITION,
      FORM_WINDOW_ID,
      TEMPLATE_WINDOW_ID,
      HEIGHT,
      WIDTH,
      INFORMATION12,
      INFORMATION13,
      INFORMATION14,
      INFORMATION15,
      INFORMATION16,
      INFORMATION5,
      INFORMATION6,
      INFORMATION7,
      INFORMATION8,
      INFORMATION9,
      INFORMATION10,
      INFORMATION11,
      Y_POSITION,
      INFORMATION_CATEGORY,
      INFORMATION1,
      INFORMATION2,
      INFORMATION3,
      INFORMATION4
    from HR_WINDOW_PROPERTIES_B
    where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID
    for update of WINDOW_PROPERTY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TITLE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_WINDOW_PROPERTIES_TL
    where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of WINDOW_PROPERTY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.INFORMATION17 = X_INFORMATION17)
           OR ((recinfo.INFORMATION17 is null) AND (X_INFORMATION17 is null)))
      AND ((recinfo.INFORMATION18 = X_INFORMATION18)
           OR ((recinfo.INFORMATION18 is null) AND (X_INFORMATION18 is null)))
      AND ((recinfo.INFORMATION19 = X_INFORMATION19)
           OR ((recinfo.INFORMATION19 is null) AND (X_INFORMATION19 is null)))
      AND ((recinfo.INFORMATION20 = X_INFORMATION20)
           OR ((recinfo.INFORMATION20 is null) AND (X_INFORMATION20 is null)))
      AND ((recinfo.INFORMATION21 = X_INFORMATION21)
           OR ((recinfo.INFORMATION21 is null) AND (X_INFORMATION21 is null)))
      AND ((recinfo.INFORMATION22 = X_INFORMATION22)
           OR ((recinfo.INFORMATION22 is null) AND (X_INFORMATION22 is null)))
      AND ((recinfo.INFORMATION23 = X_INFORMATION23)
           OR ((recinfo.INFORMATION23 is null) AND (X_INFORMATION23 is null)))
      AND ((recinfo.INFORMATION24 = X_INFORMATION24)
           OR ((recinfo.INFORMATION24 is null) AND (X_INFORMATION24 is null)))
      AND ((recinfo.INFORMATION25 = X_INFORMATION25)
           OR ((recinfo.INFORMATION25 is null) AND (X_INFORMATION25 is null)))
      AND ((recinfo.INFORMATION26 = X_INFORMATION26)
           OR ((recinfo.INFORMATION26 is null) AND (X_INFORMATION26 is null)))
      AND ((recinfo.INFORMATION27 = X_INFORMATION27)
           OR ((recinfo.INFORMATION27 is null) AND (X_INFORMATION27 is null)))
      AND ((recinfo.INFORMATION28 = X_INFORMATION28)
           OR ((recinfo.INFORMATION28 is null) AND (X_INFORMATION28 is null)))
      AND ((recinfo.INFORMATION29 = X_INFORMATION29)
           OR ((recinfo.INFORMATION29 is null) AND (X_INFORMATION29 is null)))
      AND ((recinfo.INFORMATION30 = X_INFORMATION30)
           OR ((recinfo.INFORMATION30 is null) AND (X_INFORMATION30 is null)))
      AND ((recinfo.X_POSITION = X_X_POSITION)
           OR ((recinfo.X_POSITION is null) AND (X_X_POSITION is null)))
      AND ((recinfo.FORM_WINDOW_ID = X_FORM_WINDOW_ID)
           OR ((recinfo.FORM_WINDOW_ID is null) AND (X_FORM_WINDOW_ID is null)))
      AND ((recinfo.TEMPLATE_WINDOW_ID = X_TEMPLATE_WINDOW_ID)
           OR ((recinfo.TEMPLATE_WINDOW_ID is null) AND (X_TEMPLATE_WINDOW_ID is null)))
      AND ((recinfo.HEIGHT = X_HEIGHT)
           OR ((recinfo.HEIGHT is null) AND (X_HEIGHT is null)))
      AND ((recinfo.WIDTH = X_WIDTH)
           OR ((recinfo.WIDTH is null) AND (X_WIDTH is null)))
      AND ((recinfo.INFORMATION12 = X_INFORMATION12)
           OR ((recinfo.INFORMATION12 is null) AND (X_INFORMATION12 is null)))
      AND ((recinfo.INFORMATION13 = X_INFORMATION13)
           OR ((recinfo.INFORMATION13 is null) AND (X_INFORMATION13 is null)))
      AND ((recinfo.INFORMATION14 = X_INFORMATION14)
           OR ((recinfo.INFORMATION14 is null) AND (X_INFORMATION14 is null)))
      AND ((recinfo.INFORMATION15 = X_INFORMATION15)
           OR ((recinfo.INFORMATION15 is null) AND (X_INFORMATION15 is null)))
      AND ((recinfo.INFORMATION16 = X_INFORMATION16)
           OR ((recinfo.INFORMATION16 is null) AND (X_INFORMATION16 is null)))
      AND ((recinfo.INFORMATION5 = X_INFORMATION5)
           OR ((recinfo.INFORMATION5 is null) AND (X_INFORMATION5 is null)))
      AND ((recinfo.INFORMATION6 = X_INFORMATION6)
           OR ((recinfo.INFORMATION6 is null) AND (X_INFORMATION6 is null)))
      AND ((recinfo.INFORMATION7 = X_INFORMATION7)
           OR ((recinfo.INFORMATION7 is null) AND (X_INFORMATION7 is null)))
      AND ((recinfo.INFORMATION8 = X_INFORMATION8)
           OR ((recinfo.INFORMATION8 is null) AND (X_INFORMATION8 is null)))
      AND ((recinfo.INFORMATION9 = X_INFORMATION9)
           OR ((recinfo.INFORMATION9 is null) AND (X_INFORMATION9 is null)))
      AND ((recinfo.INFORMATION10 = X_INFORMATION10)
           OR ((recinfo.INFORMATION10 is null) AND (X_INFORMATION10 is null)))
      AND ((recinfo.INFORMATION11 = X_INFORMATION11)
           OR ((recinfo.INFORMATION11 is null) AND (X_INFORMATION11 is null)))
      AND ((recinfo.Y_POSITION = X_Y_POSITION)
           OR ((recinfo.Y_POSITION is null) AND (X_Y_POSITION is null)))
      AND ((recinfo.INFORMATION_CATEGORY = X_INFORMATION_CATEGORY)
           OR ((recinfo.INFORMATION_CATEGORY is null) AND (X_INFORMATION_CATEGORY is null)))
      AND ((recinfo.INFORMATION1 = X_INFORMATION1)
           OR ((recinfo.INFORMATION1 is null) AND (X_INFORMATION1 is null)))
      AND ((recinfo.INFORMATION2 = X_INFORMATION2)
           OR ((recinfo.INFORMATION2 is null) AND (X_INFORMATION2 is null)))
      AND ((recinfo.INFORMATION3 = X_INFORMATION3)
           OR ((recinfo.INFORMATION3 is null) AND (X_INFORMATION3 is null)))
      AND ((recinfo.INFORMATION4 = X_INFORMATION4)
           OR ((recinfo.INFORMATION4 is null) AND (X_INFORMATION4 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TITLE = X_TITLE)
               OR ((tlinfo.TITLE is null) AND (X_TITLE is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_WINDOW_PROPERTY_ID in NUMBER,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_X_POSITION in NUMBER,
  X_FORM_WINDOW_ID in NUMBER,
  X_TEMPLATE_WINDOW_ID in NUMBER,
  X_HEIGHT in NUMBER,
  X_WIDTH in NUMBER,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_Y_POSITION in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_WINDOW_PROPERTIES_B set
    INFORMATION17 = X_INFORMATION17,
    INFORMATION18 = X_INFORMATION18,
    INFORMATION19 = X_INFORMATION19,
    INFORMATION20 = X_INFORMATION20,
    INFORMATION21 = X_INFORMATION21,
    INFORMATION22 = X_INFORMATION22,
    INFORMATION23 = X_INFORMATION23,
    INFORMATION24 = X_INFORMATION24,
    INFORMATION25 = X_INFORMATION25,
    INFORMATION26 = X_INFORMATION26,
    INFORMATION27 = X_INFORMATION27,
    INFORMATION28 = X_INFORMATION28,
    INFORMATION29 = X_INFORMATION29,
    INFORMATION30 = X_INFORMATION30,
    X_POSITION = X_X_POSITION,
    FORM_WINDOW_ID = X_FORM_WINDOW_ID,
    TEMPLATE_WINDOW_ID = X_TEMPLATE_WINDOW_ID,
    HEIGHT = X_HEIGHT,
    WIDTH = X_WIDTH,
    INFORMATION12 = X_INFORMATION12,
    INFORMATION13 = X_INFORMATION13,
    INFORMATION14 = X_INFORMATION14,
    INFORMATION15 = X_INFORMATION15,
    INFORMATION16 = X_INFORMATION16,
    INFORMATION5 = X_INFORMATION5,
    INFORMATION6 = X_INFORMATION6,
    INFORMATION7 = X_INFORMATION7,
    INFORMATION8 = X_INFORMATION8,
    INFORMATION9 = X_INFORMATION9,
    INFORMATION10 = X_INFORMATION10,
    INFORMATION11 = X_INFORMATION11,
    Y_POSITION = X_Y_POSITION,
    INFORMATION_CATEGORY = X_INFORMATION_CATEGORY,
    INFORMATION1 = X_INFORMATION1,
    INFORMATION2 = X_INFORMATION2,
    INFORMATION3 = X_INFORMATION3,
    INFORMATION4 = X_INFORMATION4,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HR_WINDOW_PROPERTIES_TL set
    TITLE = X_TITLE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_WINDOW_PROPERTY_ID in NUMBER
) is
begin
  delete from HR_WINDOW_PROPERTIES_TL
  where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HR_WINDOW_PROPERTIES_B
  where WINDOW_PROPERTY_ID = X_WINDOW_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HR_WINDOW_PROPERTIES_TL T
  where not exists
    (select NULL
    from HR_WINDOW_PROPERTIES_B B
    where B.WINDOW_PROPERTY_ID = T.WINDOW_PROPERTY_ID
    );

  update HR_WINDOW_PROPERTIES_TL T set (
      TITLE
    ) = (select
      B.TITLE
    from HR_WINDOW_PROPERTIES_TL B
    where B.WINDOW_PROPERTY_ID = T.WINDOW_PROPERTY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WINDOW_PROPERTY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.WINDOW_PROPERTY_ID,
      SUBT.LANGUAGE
    from HR_WINDOW_PROPERTIES_TL SUBB, HR_WINDOW_PROPERTIES_TL SUBT
    where SUBB.WINDOW_PROPERTY_ID = SUBT.WINDOW_PROPERTY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TITLE <> SUBT.TITLE
      or (SUBB.TITLE is null and SUBT.TITLE is not null)
      or (SUBB.TITLE is not null and SUBT.TITLE is null)
  ));

  insert into HR_WINDOW_PROPERTIES_TL (
    WINDOW_PROPERTY_ID,
    TITLE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.WINDOW_PROPERTY_ID,
    B.TITLE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_WINDOW_PROPERTIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_WINDOW_PROPERTIES_TL T
    where T.WINDOW_PROPERTY_ID = B.WINDOW_PROPERTY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_TITLE in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_WINDOW_ID NUMBER;
  X_TEMPLATE_WINDOW_ID NUMBER;
  X_TEMPLATE_WINDOW_CONTEXT_ID NUMBER;
  X_WINDOW_PROPERTY_ID NUMBER;
begin

  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

 select form_window_id
 into x_form_window_id
 from hr_form_windows_b
 where window_name = x_window_name
 and application_id = x_application_id
 and form_id = x_form_id;

 IF ltrim(rtrim(x_template_name)) is not null then

 select hti.template_window_id
 into x_template_window_id
 from hr_form_templates_b hft
      ,hr_template_windows_b hti
 where hti.form_window_id = x_form_window_id
 and hti.form_template_id = hft.form_template_id
 and hft.form_id = x_form_id
 and hft.application_id = x_application_id
 and (  (hft.legislation_code is null and x_territory_short_name is null)
     or (hft.legislation_code = x_territory_short_name) )
 and hft.template_name = x_template_name;

 x_form_window_id := null;
 ELSE
 x_template_window_id := null;
 END IF;

 select window_property_id
 into x_window_property_id
 from hr_window_properties_b
 where nvl(form_window_id,hr_api.g_number) =  nvl(x_form_window_id,hr_api.g_number)
 and nvl(template_window_id,hr_api.g_number) = nvl(x_template_window_id,hr_api.g_number);

 update HR_WINDOW_PROPERTIES_TL set
  TITLE = X_TITLE,
  LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
  SOURCE_LANG = userenv('LANG')
 where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
 and window_property_id = x_window_property_id;


end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_HEIGHT     in VARCHAR2,
  X_WIDTH     in VARCHAR2,
  X_X_POSITION  in VARCHAR2,
  X_Y_POSITION in VARCHAR2,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_TITLE in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_WINDOW_ID NUMBER;
  X_TEMPLATE_WINDOW_ID NUMBER;
  X_TEMPLATE_WINDOW_CONTEXT_ID NUMBER;
  X_WINDOW_PROPERTY_ID NUMBER;
begin

  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

 select form_window_id
 into x_form_window_id
 from hr_form_windows_b
 where window_name = x_window_name
 and application_id = x_application_id
 and form_id = x_form_id;

 IF ltrim(rtrim(x_template_name)) is not null THEN

 select hti.template_window_id
 into x_template_window_id
 from hr_form_templates_b hft
      ,hr_template_windows_b hti
 where hti.form_window_id = x_form_window_id
 and hti.form_template_id = hft.form_template_id
 and hft.form_id = x_form_id
 and hft.application_id = x_application_id
 and (  (hft.legislation_code is null and x_territory_short_name is null)
     or (hft.legislation_code = x_territory_short_name) )
 and hft.template_name = x_template_name;

 x_form_window_id := null;
 ELSE
  x_template_window_id := null;

 END IF;

 begin
   select window_property_id
   into x_window_property_id
   from hr_window_properties_b
   where nvl(form_window_id,hr_api.g_number) =  nvl(x_form_window_id,hr_api.g_number)
   and nvl(template_window_id,hr_api.g_number) = nvl(x_template_window_id,hr_api.g_number);
 exception
   when no_data_found then
     select hr_window_properties_b_s.nextval
     into x_window_property_id
     from dual;
 end;

 begin

  UPDATE_COPIES (
    X_WINDOW_PROPERTY_ID,
    X_FORM_WINDOW_ID,
    X_TEMPLATE_WINDOW_ID,
    X_HEIGHT,
    X_WIDTH,
    X_X_POSITION,
    X_Y_POSITION,
    X_TITLE,
    X_INFORMATION_CATEGORY,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_INFORMATION5,
    X_INFORMATION6,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    X_INFORMATION12,
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_INFORMATION29,
    X_INFORMATION30,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
    );

  UPDATE_ROW (
    X_WINDOW_PROPERTY_ID,
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_INFORMATION29,
    X_INFORMATION30,
    to_number(X_X_POSITION),
    X_FORM_WINDOW_ID,
    X_TEMPLATE_WINDOW_ID,
    to_number(X_HEIGHT),
    to_number(X_WIDTH),
    X_INFORMATION12,
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_INFORMATION5,
    X_INFORMATION6,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    to_number(X_Y_POSITION),
    X_INFORMATION_CATEGORY,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_TITLE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN);

 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_WINDOW_PROPERTY_ID,
       X_INFORMATION17,
       X_INFORMATION18,
       X_INFORMATION19,
       X_INFORMATION20,
       X_INFORMATION21,
       X_INFORMATION22,
       X_INFORMATION23,
       X_INFORMATION24,
       X_INFORMATION25,
       X_INFORMATION26,
       X_INFORMATION27,
       X_INFORMATION28,
       X_INFORMATION29,
       X_INFORMATION30,
       to_number(X_X_POSITION),
       X_FORM_WINDOW_ID,
       X_TEMPLATE_WINDOW_ID,
       to_number(X_HEIGHT),
       to_number(X_WIDTH),
       X_INFORMATION12,
       X_INFORMATION13,
       X_INFORMATION14,
       X_INFORMATION15,
       X_INFORMATION16,
       X_INFORMATION5,
       X_INFORMATION6,
       X_INFORMATION7,
       X_INFORMATION8,
       X_INFORMATION9,
       X_INFORMATION10,
       X_INFORMATION11,
       to_number(X_Y_POSITION),
       X_INFORMATION_CATEGORY,
       X_INFORMATION1,
       X_INFORMATION2,
       X_INFORMATION3,
       X_INFORMATION4,
       X_TITLE,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);
 end;
end LOAD_ROW;
end HR_WINDOW_PROPERTIES_PKG;

/
