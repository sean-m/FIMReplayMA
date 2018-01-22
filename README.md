# FIMReplayMA
FIM Replay Management Agent (MA)

# Author
Bob Bradley

# Description
The purpose of this document is to outline the steps required to create a **Replay Management Agent** (Replay MA) for your FIM Sync/ILM FP1 server.

A Replay MA is an **import only text file management agent** derived from any existing management agent by leveraging the **audit drop file** created as a by-product of either a **full or delta import run profile**.  While the concept applies to any MA, the management agent that has been targeted for this topic is the FIM MA because of the special benefits that this brings.

# Quality
Owner: Bob Bradley, FIM Team Mentor
Version 1.1

# Purpose
The concept of the Replay MA is to provide very low cost option (in terms of development as well as processing overhead) of providing the FIM Metaverse with an additional feed of the same data already present in an existing MA.  In the special case of the FIM MA, this provides added benefits, including **avoiding equal precedence** when you would not otherwise implement this feature.

The Replay MA was inspired by limitations encountered using the FIM MA …

* The FIM MA is very different from any other type
* Additional rules apply, e.g.
  * only one instance of the FIM MA allowed per sync service
  * only one FIM service connected to a single sync service
  * one-to-one “like with like” attribute mappings only
  * only direct flows configurable in the MA wizard only
  * no manual precedence allowed when FIM MA contributes an attribute value to the MV

  Constraints such as the ones above can impose solution limitations … ones that we might find ourselves looking for ways around.  The above restrictions mean that there is effectively no real flexibility around how to design configurations to achieve common synchronization requirements. Specifically there are several emerging use cases (which I will come to shortly) which can NOT be achieved using the synchronization engine and can only be approximated using custom workflow activities.  As a result, there is no documented means of using the FIM Synchronization engine to achieve certain desirable outcomes.

The Instant Replay MA is a concept which leverages standard FIM Sync Engine features in a way not considered before to allow certain configuration options that are often not possible otherwise.  Using what is essentially a read-only clone of any existing MA (including the FIM MA), any attribute can be contributed by the cloned MA in lieu of the original MA, thereby allowing for standard and extended options involving these attribute flows.

Note that the context of the remainder of this document is exclusively the FIM MA.

# Procedures
## Required start state
You will require fully operational FIM Sync and FIM Portal services, complete with an instance of the FIM MA.

You will need the FIM Identity Manager console open on the Management Agents tab, and all attributes that you wish to import must already be present and selected in the FIM MA configuration.

## Process - Replaying your FIM MA
1. Update the **existing full and delta import run profiles** used for the FIM MA to include the option for creating an audit drop file (DSML format).  Select the option where the file is created and the import continues as normal.
1. Export the FIM MA as an xml file FIMMA.xml. and save to a file location on a FIM Sync server disk drive (for the purpose of this document, let this be C:\UNIFY\FIM.ReplayMA\).
1. Run the attached PowerShell script ReplayLDIF-GenerateSchema.ps1 to generate the LDIF file schema.ldif,
1. Create a new instance of the LDAP Data Interchange Format (LDIF) text file management agent, and specify the generated schema.ldif as the LDIF template for this MA.  In completing the wizard make sure only the desired objects and attributes you wish to flow are selected and defined (delete what you don't need),  Specify either classic or declarative flow rules as desired, noting that some of the benefits of this approach arise from the use of classic direct/advanced flow rules.  Make use of csObjectID wherever possible to define join rules, since this will already guarantee unique 1-1 matching.
   The following screen-shots are examples of how this MA can be configured:
   ![properties](https://github.com/themimteam/FIMReplayMA/blob/master/01.properties.png)
   ![Configure Attributes](https://github.com/themimteam/FIMReplayMA/blob/master/02.configureAttributes.png)
   ![Map Object Types](https://github.com/themimteam/FIMReplayMA/blob/master/03.mapObjectTypes.png)
   ![Define Object Types](https://github.com/themimteam/FIMReplayMA/blob/master/04.defineObjectTypes.png)
   ![Configure Join and Projection Rules](https://github.com/themimteam/FIMReplayMA/blob/master/05.configureJoinAndProjectionRules.png)
   ![Configure Attribute Flow](https://github.com/themimteam/FIMReplayMA/blob/master/06.configureAttributeFlow.png)
1. Create and build whatever rules extensions are required to support your MA configuration.
1. Define all necessary run profiles for your new Replay MA.
1. Extend the operational process defined to execute FIM MA with a post-processing script ReplayLDIF-GenerateData.ps1 to transform the generated DSML drop files generated by both the full and delta import run profiles and save them to the MAData folder of the FIM Replay MA.  This script uses XSLT stylesheets to transform DSML files to LDIF format.
1. Execute full and/or delta import FIM MA run profiles to generate the input DSML drop files.
1. Execute your script to generate the appropriate full or delta LDIF input file.
1. Execute the corresponding Replay MA run full and/or delta import run profile

## Process - Replaying your ADDS MA
As per the above, but replacing the FIM MA with an ADDS MA instance, noting that the ReplayLDIF-GenerateData.ps1 script must be called with the 2 alternative ADDS XSLT files XMLtoLDIF-Full.AD.xslt and XMLtoLDIF-Delta.AD.xslt specified as parameters to override the default (built for the FIM MA) you will find in your download from this site.  These new XSLT files are specifically targeted to one particular use case at this stage (see below).

# Use Case Scenarios
* Eliminate the need to configure "equal precedence" for scenarios where there is no alternative when involving the FIM MA
  There are several scenarios here (e.g. group membership for migrated groups should become authoritative in the portal post migration) which are presently not achievable without configuring equal precedence.  This is always problematic and would be good to avoid by introducing a 3rd authoritative source for group membership which can trump the others.

* Provide a means for FIM portal attributes to be used to derive additional columns (incl. in advanced attribute flows).
  The FIM MA allows only direct 1-1 attribute flows between like object classes in the FIM Portal and the FIM Metaverse using fixed class schema.  One scenario is where you wish to join on something other than the mv GUID – e.g. on the manager attribute so as to enable flow of the manager display name (redundantly) to the subordinate.

* Provide a means for FIM portal attributes to be used to be treated as different attribute types (incl. in advanced attribute flows).
  The FIM MA allows only direct 1-1 attribute flows between like object classes in the FIM Portal and the FIM Metaverse using fixed class schema.  This prevents the use of advanced flow rules in such cases as only flowing reference attributes based on the value of another attribute of the same identity, or flowing reference types as strings to allow for advanced flow rules.
  * Note: there is a documented alternative (advanced) for this scenario when working with Portal sync rules.

* Provide a means to define MANUAL precedence by enabling advanced attribute flows (rules extensions) from the FIM Portal
  The FIM MA allows only direct 1-1 attribute flows, and as a result any attribute contributed by the FIM Portal cannot be included in a “manual precedence rule” when the FIM MA is the only means of sourcing this attribute from the FIM Portal

  The attached PowerPoint show illustrates 3 use case variations:

  FIMReplayMA.UseCases.ppsx

# Additional Use Cases
* Spread the synchronization load for the FIM service across multiple synchronization services
  As explained above, anyone who has ever installed FIM will know that you are only ever allowed one FIM MA with every FIM Synchronization Service.  This is because of the tight coupling between them, and the general principle that where MV data is to be provisioned to/synchronized with/projected from its corresponding FIM Service binding, this should only be done on a 1-1 basis (and vice versa).  Additionally there is "background integration" which goes on whenever config is changed (ma-data and mv-data resources) that bypasses the FIM MA entirely, but uses the FIM MA settings to drive connectivity.
  However, by using the Replay MA idea we can take the CS of the FIM MA for the "primary" synchronization service and replay it through any number of "secondary" synchronization services.
  For more details, please refer to this blog entry.
* Derive multi-value FIM metaverse reference attribute user.memberOf from group.member
  As described in this blog post you can apply the Replay MA idea to any MA, not just the FIM MA.  In this particular use case I needed a way of calling the MSOL PowerShell interface (via a PowerShell MA) to assign licenses according to user group membership - noting that you can't do this with just the ADDS MA alone as the user.memberOf attribute you see in the ADUC console is actually virtual and can not be replicated to FIM in the standard way.  Of course there are other uses too ... such as defining FIM sets based on ADDS group membership.  There are also other reasons to replay an ADDS MA, but the only one I've supported for you right now is this one - feel free to extend this as you see fit.
  There is one important point you need to be aware of when using this however - you will need to rely on a FULL IMPORT step to remove groups from user.memberOf when a corresponding deletion occurs from group.member in the source - this is because the XML audit file generated on a delta import only contains details of the latest group membership, not what it was previously, and therefore the only group membership ADDITIONS are supported by the delta.  Generally this is workable, however, since most interest from a timeliness perspective tends to be in new membership, and you can generally wait until an overnight FI/DS run to "clean up" deleted membership.

# Notes
1. The attached scripts are made available for use in the above process under the UNIFY Free BSD 2-clause license agreement.
1. When Importing through the Replay MA and Exporting the same attribute through the FIM MA it is recommended that "Allow Nulls" is not ticked. This avoids the possibility that a mistake in the flow from the Replay MA results in a null value in the Metaverse and subsequest deletion of the value in the FIM Portal.
1. Carriage returns in an attribute can cause problems with the formatting of the LDIF file. Either remove the carriage returns, exclude the attribute from the FIM MA (it must be completely excluded by MPR permissions - it is not enough to untick it in the MA), or modify the XSL stylesheets to exclude the attribute from the Replay MA.
1. Some more advanced use cases involving the creation of "back links" are excluded from the scope of version 1 of this solution, although I have included an attribute flow screenshot showing how these can be used.  It is anticipated that a subsequent version of this MA will be made available to support these additional use cases, but only version 1 will be available under the UNIFY BSD License Agreement.
