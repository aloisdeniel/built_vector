# built_vector

Generates Flutter vector code from minimalist SVG-like files.

## Usage

```sh
> pub global activate built_vector
> pub global run built_vector -i <assets file path> -o <output dart file>
```

A class named accordingly to your assets node's name, containing a `void Paint(Canvas canvas, Size size, {Color fill})` function for each vector node.

You can then use them with a custom painter, like with the [sample/lib/vectors.dart](sample/lib/vectors.dart) `Vector` widget.

## File format

### Assets

An asset catalog is a collection of assets (`vector` only at the moment).

```xml
<assets name="icons">
    <vector ... />
    <vector ... />
    <vector ... />
</assets>
```

### Vector

A vector is a collection of filled shapes.

It has several properties :

* `name` **(required)** : the identifier of the vector asset
* `viewBox` **(required)** : a box (`<x> <y> <width> <height>`)that contains all the shapes.
* `fill` : a default fill brush for shapes

```xml
<vector name="warning" viewBox="0 0 24 24" fill="#231F20">
    <rect ... />
    <circle ... />
    <path ... />
</vector>
```

### Shape

A shape is a set of instructions to build an area to fill with a brush. Currently it can be `rect`, `circle`, `path`. 

It has several properties :

* `fill` : a default fill brush for shapes
* `rect` - `x`, `y`, `width`, `height` : position and size
* `circle` - `cx`, `cy`, `r` : center coordinates and radius
* `path` - `d` : SVG path data 


```xml
<vector name="warning" viewBox="0 0 24 24" fill="#231F20">
    <rect x="15" y="14" width="31" height="28" />
    <circle cx="45.5" cy="42.5" r="15.5" fill="#C4C4C4" />
    <path d="M12 17C12.5523 17 13 16.5523 13 16C13 15.4477 12.5523 15 12 15C11.4477 15 11 15.4477 11 16C11 16.5523 11.4477 17 12 17Z" />
</vector>
```

## Sample

To generate the sample, execute :

```sh
> pub global run built_vector -i sample/assets/icons.assets -o sample/lib/icons.g.dart
```

 The [sample/assets/icons.assets](sample/assets/icons.assets) file is generated as [sample/lib/icons.g.dart](sample/lib/icons.g.dart).