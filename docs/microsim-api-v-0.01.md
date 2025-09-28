# A Simple API For Controlling Microsimulation Models

v0.0.1 September 2025

graham.stark@northumbria.ac.uk

## Objective

control any .. canonical is Tax Benefit model

### In Scope

control and display a single run of an arbitrary model
in any language
discover the structure of the model at run-time or in advance

### Out-of-Scope

Authentication
Long-term users - previous results, etc.

### Tech

* REST API
* JSON
* Markdown

### Example API

```

api.scotben.virtual-worlds.scot

/session/start
/session/destroy

/params/set
/params/validate
/params/describe
/params/defaults
/params/page
/params/helppage
/params/labels

or /params/[sysno]/tax/set ... for individual pages

/settings/set
/settings/validate
...

/run/submit
/run/status
/run/abort

/output/items
/output/phunpak
/output/labels
/output/fetch/item


```

### Single vs Multishot 

## Structure of a Model

### Parameters vs Settings

### Outputs 

## Running 

### State Queries

## A simple worked example