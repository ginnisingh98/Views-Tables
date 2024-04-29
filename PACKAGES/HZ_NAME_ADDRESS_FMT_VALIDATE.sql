--------------------------------------------------------
--  DDL for Package HZ_NAME_ADDRESS_FMT_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_NAME_ADDRESS_FMT_VALIDATE" AUTHID CURRENT_USER AS
/*$Header: ARH2FMVS.pls 115.2 2002/11/21 06:12:16 sponnamb noship $ */

  --------------------------------------
  -- declaration of public procedures and functions
  --------------------------------------

  --
  -- PROCEDURE validate_style
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_style_rec              Style record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style(
      p_create_update_flag             IN     VARCHAR2,
      p_style_rec                      IN     HZ_STYLE_V2PUB.STYLE_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );

  --
  -- PROCEDURE validate_style_format
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_style_format_rec       Style Format record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_format(
      p_create_update_flag             IN     VARCHAR2,
      p_style_format_rec               IN     HZ_STYLE_FORMAT_V2PUB.STYLE_FORMAT_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );


  --
  -- PROCEDURE validate_style_fmt_locale
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_style_fmt_locale_rec   Style Locale record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_fmt_locale(
      p_create_update_flag             IN     VARCHAR2,
      p_style_fmt_locale_rec           IN     HZ_STYLE_FMT_LOCALE_V2PUB.STYLE_FMT_LOCALE_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );


  --
  -- PROCEDURE validate_style_fmt_variation
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag       Create update flag. 'C' = create. 'U' = update.
  --     p_style_fmt_variation_rec  Style Locale record.
  --     p_rowid                    Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status            Return status after the call. The status can
  --                                be FND_API.G_RET_STS_SUCCESS (success),
  --                                FND_API.G_RET_STS_ERROR (error),
  --                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_fmt_variation(
      p_create_update_flag             IN     VARCHAR2,
      p_style_fmt_variation_rec        IN     HZ_STYLE_FMT_VARIATION_V2PUB.STYLE_FMT_VARIATION_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );


  --
  -- PROCEDURE validate_style_fmt_layout
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag       Create update flag. 'C' = create. 'U' = update.
  --     p_style_fmt_layout_rec     Style Locale record.
  --     p_rowid                    Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status            Return status after the call. The status can
  --                                be FND_API.G_RET_STS_SUCCESS (success),
  --                                FND_API.G_RET_STS_ERROR (error),
  --                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_fmt_layout(
      p_create_update_flag             IN     VARCHAR2,
      p_style_fmt_layout_rec           IN     HZ_STYLE_FMT_LAYOUT_V2PUB.STYLE_FMT_LAYOUT_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );

END HZ_NAME_ADDRESS_FMT_VALIDATE;

 

/
