--------------------------------------------------------
--  DDL for Package JDR_CUSTOM_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JDR_CUSTOM_INTERNAL" AUTHID CURRENT_USER AS
/* $Header: JDRCTINS.pls 120.3 2005/10/26 06:15:11 akbansal noship $ */
  -- Retrieves all active customization documents corresponding
  -- to the given base document and customization layers.
  --
  -- For customization layer i, lyrtypes[i] refers to the layer
  -- type, and lyrvalues[i] refers to its value
  --
  -- If a customization doc exists for a given layer, the doc name and
  -- layer type will be retrieved in precedence order
  -- Parameters:
  --   baseDoc     - the fully qualified name of the base document.
  --   layerTypes  - an array of customization layer types
  --   layerValues - an array of customization layer values
  --   validTypes  - a returned array of existing customization types
  --   custDocs    - a returned array of existing customization documents
  --
  PROCEDURE getActiveLayers(baseDoc   IN  VARCHAR2,
                           lyrTypes   IN  jdr_stringArray,
                           lyrValues  IN  jdr_stringArray,
                           validTypes OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                           custDocs   OUT NOCOPY /* file.sql.39 change */ jdr_stringArray);
  --
  -- Retrieves a list of all customization documents corresponding to the given
  -- base document.
  --
  PROCEDURE getCustomizationDocs(baseDoc    IN  VARCHAR2,
                                 custDocs   OUT NOCOPY /* file.sql.39 change */ jdr_stringArray);

  -- Retrieves both active and inactive customization documents corresponding
  -- to the given base document and customization layers.
  --
  -- For customization layer i, lyrtypes[i] refers to the layer
  -- type, and lyrvalues[i] refers to its value
  --
  -- If a customization doc exists for a given layer, the doc name and
  -- layer type will be retrieved in precedence order
  -- Parameters:
  --   baseDoc     - the fully qualified name of the base document.
  --   layerTypes  - an array of customization layer types
  --   layerValues - an array of customization layer values
  --   validTypes  - a returned array of existing customization types
  --   custDocs    - a returned array of existing customization documents
  --
  PROCEDURE getLayers(baseDoc    IN  VARCHAR2,
                      lyrTypes   IN  jdr_stringArray,
                      lyrValues  IN  jdr_stringArray,
                      validTypes OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                      custDocs   OUT NOCOPY /* file.sql.39 change */ jdr_stringArray);

  --
  -- This procedure should only be called by the customer migration
  -- utility.  It will move the shared customizations on the "region"
  -- document, to per instance customizations on the "page" document.
  --
  -- The customer migration utility should call this when a region, which
  -- previously had been inlined in a page, has been moved to its own
  -- document; and when the new region has customizations associated with it.
  --
  -- The "region" document will refer to the customization document associated
  -- with the region which has been refactored out of the page.  The "page"
  -- document will refer to the customization document associated with the
  -- page that had previously contained the region.
  --
  -- This method will do the following:
  --
  -- (1) If the "page" document does not contain any references to the
  --     "region" document (i.e. it does not contain any customizations
  --     applicable to the region), then it converts the shared customizations
  --     on the region to per instance customizations on the page.
  --
  -- (2) If the page document does contain references to the region document,
  --     then the page customization document will remain unchanged.
  --
  -- (3) Any translations on the region document will be migrated to the
  --     page document.
  --
  -- (4) Regardless of whether or not the customizations were migrated, the
  --     region document will be deleted, as well as any translations on the
  --     region document.
  --
  -- Limitations:
  --
  -- (1) This assumes that the customization documents follow the format of
  --     the documents created by JRAD.  Specifically, jrad tags must not be
  --     prefaced with a namespace, but should be in the default namespace.
  --     For example, the views tage should look like:
  --       <views ...>
  --     not:
  --       <jrad:views ...>
  --
  -- (2) It is assumed that the extending region is not a top level
  --     component.  This will not work correctly if the extending region is
  --     a top level component.
  --
  -- (3) It is assumed that the name of the region customization document
  --     is in the old style naming.
  --
  -- Parameters:
  --   regionCustDocName    - the fully qualified name of the customization
  --                          document for the region
  --   extendingRegionName  - the fully qualified name of the extending region
  --
  PROCEDURE migrateCustomizationsToPage(regionCustDocName     IN VARCHAR2,
                                        extendingRegionName   IN VARCHAR2);

  -- Sorts an array of layer types into precedence order
  --
  -- result: lyrTypes.FIRST has lowest precedence
  --         lyrTypes.LAST  has highest precedence
  PROCEDURE sortLayers(lyrTypes  IN OUT NOCOPY /* file.sql.39 change */ jdr_stringArray);

END;

 

/
